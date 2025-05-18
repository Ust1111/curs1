import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @EnvironmentObject var recipeStore: RecipeStore
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var cookingTime = ""
    @State private var ingredients: [Ingredient] = []
    @State private var newName = ""
    @State private var newQuantity = ""
    @State private var steps: [String] = []
    @State private var newStep = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Название рецепта", text: $title)
                    .textFieldStyle(.roundedBorder)

                TextField("Время готовки (в минутах)", text: $cookingTime)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                Text("Ингредиенты").font(.headline)
                ForEach(ingredients) { ing in
                    Text("\(ing.name): \(ing.quantity)")
                }
                HStack {
                    TextField("Название", text: $newName)
                    TextField("Объём", text: $newQuantity)
                    Button {
                        guard !newName.isEmpty, !newQuantity.isEmpty else { return }
                        ingredients.append(Ingredient(name: newName, quantity: newQuantity))
                        newName = ""
                        newQuantity = ""
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }

                Text("Шаги приготовления").font(.headline)
                ForEach(steps.indices, id: \.self) { i in
                    Text("\(i + 1). \(steps[i])")
                }
                HStack {
                    TextField("Новый шаг", text: $newStep)
                    Button {
                        guard !newStep.isEmpty else { return }
                        steps.append(newStep)
                        newStep = ""
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }

                Spacer().frame(height: 20)

                PhotosPicker("Добавить изображение", selection: $selectedImage, matching: .images)
                    .onChange(of: selectedImage) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data),
                               let compressedData = image.jpegData(compressionQuality: 0.4) {
                                imageData = compressedData
                            }
                        }
                    } 

                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                }

                Button(action: saveRecipe) {
                    Text("Сохранить рецепт")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    private func saveRecipe() {
        hideKeyboard()

        if title.isEmpty || ingredients.isEmpty || steps.isEmpty {
            print("Все поля должны быть заполнены")
            return
        }

        let cleanedTime = cookingTime
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "мин", with: "")
            .replacingOccurrences(of: " ", with: "")

        guard let cookingTimeInt = Int(cleanedTime) else {
            print("Ошибка: неверное значение времени")
            return
        }

        // Сохранение изображения
        var imageDataForSaving: Data? = nil
        if let imageData = imageData {
            imageDataForSaving = imageData
        }

        let recipe = Recipe(
            title: title,
            ingredients: ingredients,
            steps: steps,
            cookingTime: cookingTimeInt,
            views: 0,
            createdAt: Date(),
            isUserRecipe: true,
            imageData: imageDataForSaving
        )

        recipeStore.addRecipe(recipe)
        dismiss()
        title = ""
        cookingTime = ""
        ingredients = []
        steps = []
        imageData = nil
        selectedImage = nil
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
