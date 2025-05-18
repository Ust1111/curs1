import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var recipeStore: RecipeStore
    @State private var searchText = ""
    @FocusState private var isFocused: Bool
    @State private var path: [Recipe] = []
    @State private var selectedCategory: String = "Все"
    @State private var maxCookingTime: String = ""
    @State private var filteredRecipes: [Recipe] = []
    
    private var userRecipes: [Recipe] {
        recipeStore.recipes
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    private var popularRecipes: [Recipe] {
        recipeStore.popularRecipes
            .filter { $0.category == "Популярные" }
            .sorted { $0.id?.components(separatedBy: "_").last ?? "" < $1.id?.components(separatedBy: "_").last ?? "" }
    }
    
    private var ghibliRecipes: [Recipe] {
        recipeStore.popularRecipes
            .filter { $0.category == "Гибли" }
            .sorted { $0.id?.components(separatedBy: "_").last ?? "" < $1.id?.components(separatedBy: "_").last ?? "" }
    }
    
    private var hogwartsRecipes: [Recipe] {
        recipeStore.popularRecipes
            .filter { $0.category == "Хогвартс" }
            .sorted { $0.id?.components(separatedBy: "_").last ?? "" < $1.id?.components(separatedBy: "_").last ?? "" }
    }
    
    private var genshinRecipes: [Recipe] {
        recipeStore.popularRecipes
            .filter { $0.category == "Геншин" }
            .sorted { $0.id?.components(separatedBy: "_").last ?? "" < $1.id?.components(separatedBy: "_").last ?? "" }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Кнопка перехода на страницу фильтров
                    NavigationLink(destination: FilterView(filteredRecipes: $filteredRecipes)) {
                        Text("Поиск")
                            .foregroundColor(.blue)
                            .padding(.top)
                    }
                    
                    // Ваши рецепты
                    if !userRecipes.isEmpty {
                        Section(header: Text("Ваши рецепты").font(.headline)) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(userRecipes) { recipe in
                                        RecipeCardView(recipe: recipe) {
                                            path.append(recipe)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Популярные рецепты
                    Section(header: Text("Популярные").font(.headline)) {
                        if popularRecipes.isEmpty {
                            Text("Нет популярных рецептов.")
                                .foregroundColor(.gray)
                                .padding(.leading)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(popularRecipes) { recipe in
                                        RecipeCardView(recipe: recipe) {
                                            path.append(recipe)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Категория: Гибли
                    Section(header: Text("Рецепты из Гибли").font(.headline)) {
                        if ghibliRecipes.isEmpty {
                            Text("Нет рецептов в этой категории.")
                                .foregroundColor(.gray)
                                .padding(.leading)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(ghibliRecipes) { recipe in
                                        RecipeCardView(recipe: recipe) {
                                            path.append(recipe)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Категория: Хогвартс
                    Section(header: Text("Рецепты из Хогвартса").font(.headline)) {
                        if hogwartsRecipes.isEmpty {
                            Text("Нет рецептов в этой категории.")
                                .foregroundColor(.gray)
                                .padding(.leading)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(hogwartsRecipes) { recipe in
                                        RecipeCardView(recipe: recipe) {
                                            path.append(recipe)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Категория: Геншин
                    Section(header: Text("Рецепты из Геншина").font(.headline)) {
                        if genshinRecipes.isEmpty {
                            Text("Нет рецептов в этой категории.")
                                .foregroundColor(.gray)
                                .padding(.leading)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(genshinRecipes) { recipe in
                                        RecipeCardView(recipe: recipe) {
                                            path.append(recipe)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Мой Рецептник")
            .onTapGesture {
                isFocused = false
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
                    .environmentObject(recipeStore)
            }
        }
    }
}
