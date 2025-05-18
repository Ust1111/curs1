import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "house")
                }
            AddRecipeView()
                .tabItem {
                    Label("Добавить", systemImage: "plus.circle")
                }
            MyRecipesView()
                .tabItem {
                    Label("Мои рецепты", systemImage: "book")
                }
        }
    }
}
