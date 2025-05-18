import SwiftUI

struct FilterView: View {
    @EnvironmentObject private var recipeStore: RecipeStore
    @Binding var filteredRecipes: [Recipe]
    @State private var searchText = ""
    @State private var selectedCategory = "Все"
    @State private var maxCookingTime = ""
    @State private var selectedRecipe: Recipe? = nil
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { hideKeyboard() }
                .ignoresSafeArea()

            VStack {
                TextField("Поиск по названию или ингредиентам", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Максимальное время (мин)", text: $maxCookingTime)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Picker("Категория", selection: $selectedCategory) {
                    Text("Все").tag("Все")
                    Text("Мои рецепты").tag("Мои рецепты")
                    ForEach(["Гибли", "Хогвартс", "Геншин", "Популярные"], id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Button("Применить фильтры") {
                    applyFilters()
                }
                .padding()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredRecipes) { recipe in
                            RecipeCardView(recipe: recipe) {
                                selectedRecipe = recipe
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Поиск")
        .onAppear {
            // Initialize with all recipes
            filteredRecipes = Array(Set(recipeStore.allRecipes))
        }
        .sheet(item: $selectedRecipe) { recipe in
            NavigationView {
                RecipeDetailView(recipe: recipe)
            }
        }
    }
    
    private func applyFilters() {
        hideKeyboard()
        
        // Start with all recipes and remove duplicates
        var recipes = Array(Set(recipeStore.allRecipes))
        
        // Apply category filter
        if selectedCategory != "Все" {
            if selectedCategory == "Мои рецепты" {
                recipes = recipes.filter { $0.isUserRecipe }
            } else {
                recipes = recipes.filter { $0.category == selectedCategory }
            }
        }
        
        // Apply search text filter
        if !searchText.isEmpty {
            recipes = recipes.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply cooking time filter
        if let maxTime = Int(maxCookingTime), maxTime > 0 {
            recipes = recipes.filter { $0.cookingTime <= maxTime }
        }
        
        // Sort by views first, then by date for equal view counts
        recipes.sort { first, second in
            if first.views != second.views {
                return first.views > second.views
            }
            return first.createdAt > second.createdAt
        }
        
        filteredRecipes = recipes
    }
}
