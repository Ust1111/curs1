import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject var recipeStore: RecipeStore
    @Environment(\.dismiss) var dismiss

    var recipe: Recipe
    @State private var showEditView = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                }

                Text(recipe.title)
                    .font(.largeTitle)
                    .bold()

                Text("Время приготовления: \(recipe.cookingTime) мин")
                    .font(.subheadline)

                Divider()

                Text("Ингредиенты")
                    .font(.headline)
                ForEach(recipe.ingredients, id: \.id) { ingredient in
                    Text("- \(ingredient.name): \(ingredient.quantity)")
                }

                Divider()

                Text("Шаги приготовления")
                    .font(.headline)
                ForEach(recipe.steps.indices, id: \.self) { i in
                    Text("\(i + 1). \(recipe.steps[i])")
                }

                if recipe.isUserRecipe {
                    HStack {
                        Button("Редактировать") {
                            showEditView = true
                        }
                        .buttonStyle(.bordered)

                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Text("Удалить")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .onAppear {
            recipeStore.markAsViewed(recipe)
        }
        .sheet(isPresented: $showEditView) {
            EditRecipeView(recipe: recipe)
                .environmentObject(recipeStore)
        }
        .alert("Удалить рецепт?", isPresented: $showDeleteConfirmation) {
            Button("Удалить", role: .destructive) {
                recipeStore.deleteRecipe(recipe)
                dismiss()
            }
            Button("Отмена", role: .cancel) {}
        }
        .onReceive(recipeStore.$recipes) { _ in
            // Only check and dismiss if this is a user recipe that's been deleted
            if recipe.isUserRecipe && !recipeStore.recipes.contains(where: { $0.id == recipe.id }) {
                dismiss()
            }
        }
    }
}
