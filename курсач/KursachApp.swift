import SwiftUI
import FirebaseCore

@main
struct KursachApp: App {
    // Подключаем AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject var recipeStore = RecipeStore()
    
    var body: some Scene {
        WindowGroup {
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
            .environmentObject(recipeStore)
        }
    }
}

// Оставляем AppDelegate как есть
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
