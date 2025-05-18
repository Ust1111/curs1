import SwiftUI

struct MyRecipesView: View {
    @EnvironmentObject private var recipeStore: RecipeStore

    private var sortedRecipes: [Recipe] {
        recipeStore.recipes.sorted { $0.title < $1.title }
    }

    var body: some View {
        NavigationView {
            if recipeStore.recipes.isEmpty {
                emptyStateView
            } else {
                recipesList
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("У вас пока нет рецептов")
                .font(.title3)
            NavigationLink(destination: AddRecipeView()) {
                Label("Добавить рецепт", systemImage: "plus")
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }

    private var recipesList: some View {
        List {
            ForEach(sortedRecipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeCardView(recipe: recipe)
                }
            }
            .onDelete(perform: deleteRecipes)
        }
        .navigationTitle("Мои рецепты")
    }

    private func deleteRecipes(at offsets: IndexSet) {
        withAnimation {
            let recipesToDelete = offsets.map { sortedRecipes[$0] }
            recipesToDelete.forEach { recipe in
                recipeStore.deleteRecipe(recipe)
            }
        }
    }
}
