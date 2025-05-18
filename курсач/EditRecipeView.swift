import SwiftUI
import PhotosUI

struct EditRecipeView: View {
    @EnvironmentObject private var recipeStore: RecipeStore
    @Environment(\.dismiss) var dismiss

    var recipe: Recipe

    @State private var title: String
    @State private var cookingTime: String
    @State private var ingredients: [Ingredient]
    @State private var newName = ""
    @State private var newQuantity = ""
    @State private var steps: [String]
    @State private var newStep = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?

    init(recipe: Recipe) {
        self.recipe = recipe
        _title = State(initialValue: recipe.title)
        _cookingTime = State(initialValue: "\(recipe.cookingTime)")
        _ingredients = State(initialValue: recipe.ingredients)
        _steps = State(initialValue: recipe.steps)
        _imageData = State(initialValue: recipe.imageData)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Название рецепта", text: $title)
                    .textFieldStyle(.roundedBorder)

                TextField("Время готовки (в минутах)", text: $cookingTime)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                Text("Ингредиенты")
                    .font(.headline)

                ForEach(ingredients.indices, id: \.self) { i in
                    HStack {
                        TextField("Название", text: $ingredients[i].name)
                            .textFieldStyle(.roundedBorder)
                        TextField("Объём", text: $ingredients[i].quantity)
                            .textFieldStyle(.roundedBorder)
                        Button(action: {
                            ingredients.remove(at: i)
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
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

                Text("Шаги приготовления")
                    .font(.headline)

                ForEach(steps.indices, id: \.self) { i in
                    HStack {
                        TextField("Шаг \(i + 1)", text: $steps[i])
                            .textFieldStyle(.roundedBorder)
                        Button(action: {
                            steps.remove(at: i)
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
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

                PhotosPicker("Обновить изображение", selection: $selectedImage, matching: .images)
                    .onChange(of: selectedImage) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data),
                               let compressedData = image.jpegData(compressionQuality: 0.4) {
                                imageData = compressedData
                            }
                        }
                    }

                Button("Сохранить изменения") {
                    saveChanges()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .onTapGesture {
            hideKeyboard() // Вызываем метод из другого файла
        }
    }

    private func saveChanges() {
        hideKeyboard()

        guard !title.isEmpty, !ingredients.isEmpty, !steps.isEmpty else {
            print("Заполните все поля")
            return
        }

        guard let cookingTimeInt = Int(cookingTime) else {
            print("Неверный формат времени")
            return
        }

        let updatedRecipe = Recipe(
            id: recipe.id,
            title: title,
            ingredients: ingredients,
            steps: steps,
            cookingTime: cookingTimeInt,
            views: recipe.views,
            createdAt: recipe.createdAt,
            category: recipe.category,
            isUserRecipe: true,
            imageData: imageData
        )

        recipeStore.updateRecipe(updatedRecipe)
        dismiss()
    }
}
