import FirebaseFirestore
import Combine

class RecipeStore: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var popularRecipes: [Recipe] = []
    @Published var viewedRecipes: [Recipe] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    var allRecipes: [Recipe] {
        // Keep only user recipes and popular recipes separate
        recipes + popularRecipes.filter { recipe in
            !recipes.contains { $0.id == recipe.id }
        }
    }
    
    init() {
        setupPopularRecipes()
        setupFirestoreListener()
    }
    
    deinit {
        listener?.remove()
    }
    
    private func setupPopularRecipes() {
        // Define ID prefixes for each category
        let hogwartsPrefix = "hogwarts_"
        let popularPrefix = "popular_"
        let genshinPrefix = "genshin_"
        let ghibliPrefix = "ghibli_"
        
        // Хогвартс recipes
        let slivochnoePivo = Recipe(
            id: "\(hogwartsPrefix)1",
            title: "Сливочное пиво",
            ingredients: [
                Ingredient(name: "Молоко", quantity: "по вкусу"),
                Ingredient(name: "Сливки 33%", quantity: "по вкусу"),
                Ingredient(name: "Имбирная карамель", quantity: "по вкусу"),
                Ingredient(name: "Пюре из тыквы", quantity: "по вкусу"),
                Ingredient(name: "Имбирная смесь специй", quantity: "по вкусу")
            ],
            steps: [
                "Вылейте молоко в ковш и поставьте на слабый огонь.",
                "Добавьте имбирную смесь специй и хорошо перемешайте.",
                "Дайте молоку нагреяться до теплого состояния.",
                "Взбейте сливки до мягких пиков и добавьте в стакан с молоком."
            ],
            cookingTime: 15,
            views: 100,
            createdAt: Date(),
            category: "Хогвартс",
            isUserRecipe: false
        )
        
        let zharkoe = Recipe(
            id: "\(hogwartsPrefix)2",
            title: "Жаркое",
            ingredients: [
                Ingredient(name: "Свинина", quantity: "по вкусу"),
                Ingredient(name: "Чеснок", quantity: "по вкусу"),
                Ingredient(name: "Тимьян", quantity: "по вкусу"),
                Ingredient(name: "Соль", quantity: "по вкусу"),
                Ingredient(name: "Папричный соус", quantity: "по вкусу"),
                Ingredient(name: "Заправка для жаркого", quantity: "по вкусу"),
                Ingredient(name: "Сахар", quantity: "по вкусу"),
                Ingredient(name: "Перец гриль", quantity: "по вкусу"),
                Ingredient(name: "Картофель", quantity: "по вкусу")
            ],
            steps: [
                "В глубокую большую сковороду добавьте 2 ст. ложки растительного масла и разогрейте на сильном огне.",
                "В сковороду положите свинину (без жидкости) и чеснок.",
                "Моем свежий тимьян, отрываем листочки и добавляем в сковороду.",
                "Посыпаем 0,25 ч. ложки соли.",
                "Помешиваем все вместе в течение 3 минут.",
                "Добавьте папричный соус и помешивайте еще 30 секунд.",
                "Постепенно добавьте заправку для жаркого, специи (по желанию), 1/2 ч. ложки сахара и 3 ст. ложки воды комнатной температуры.",
                "Помешиваем еще 30 секунд.",
                "Добавьте перец гриль (без жидкости) и готовый картофель в сковороду. Перемешайте.",
                "Накройте крышкой и уменьшите огонь до слабого. Оставьте на 1 минуту.",
                "Снимите с огня и разложите по тарелкам."
            ],
            cookingTime: 30,
            views: 80,
            createdAt: Date(),
            category: "Хогвартс",
            isUserRecipe: false
        )
        
        let yorkshirePudding = Recipe(
            id: "\(hogwartsPrefix)3",
            title: "Йоркширские пудинги",
            ingredients: [
                Ingredient(name: "Молоко 3,2%", quantity: "по вкусу"),
                Ingredient(name: "Лук", quantity: "по вкусу"),
                Ingredient(name: "Пшеничная мука", quantity: "по вкусу"),
                Ingredient(name: "Яйца", quantity: "по вкусу"),
                Ingredient(name: "Свежий тимьян", quantity: "по вкусу"),
                Ingredient(name: "Маринованная индейка для ростбифа", quantity: "по вкусу")
            ],
            steps: [
                "Включите духовку на максимум 220-250℃ в режиме верх-низ.",
                "Разместите формочки на противне и добавьте в каждую по 1-2 ст. ложки растительного масла.",
                "Поместите противень в разогретую духовку на 15 минут.",
                "Для теста: 1. Моем 2 яйца и разбиваем их в миску. Взбиваем вилкой или венчиком.  2. Добавляем 0,25 ч. ложки соли, 1 ч. ложку сахара и молоко в миску. Хорошо перемешиваем.  3. Постепенно добавляем пшеничную муку и продолжаем перемешивать до получения однородного теста.",
                "Для индейки: 1. Очистите лук, разрежьте его на 8 частей и поместите в форму.  2. Выложите маринованную индейку (без маринада) на лук.  3. Положите веточку свежего тимьяна сверху.",
                "Когда прошло 15 минут, осторожно выньте противень из духовки.",
                "Ложкой положите каплю теста в формочку с маслом. Если не начинает шипеть, верните формочки с маслом в духовку еще на 5 минут. Если начало шипеть, равномерно распределите тесто по формочкам с помощью столовой ложки.",
                "Поставьте форму с индейкой на противень рядом с другими формочками.",
                "Уменьшите температуру духовки до 200℃ и отправьте противень снова в духовку на 25 минут.",
                "После готовности индейки, нарежьте ее ломтиками и разложите по тарелкам. Рядом подайте йоркширские пудинги."
            ],
            cookingTime: 60,
            views: 60,
            createdAt: Date(),
            category: "Хогвартс",
            isUserRecipe: false
        )

        // Популярные recipes
        let pastushiyPirog = Recipe(
            id: "\(popularPrefix)1",
            title: "«Пастуший пирог» по-шотландски",
            ingredients: [
                Ingredient(name: "Картофельное пюре", quantity: "по вкусу"),
                Ingredient(name: "Мясное рагу болоньезе", quantity: "по вкусу"),
                Ingredient(name: "Сыр моцарелла", quantity: "по вкусу"),
                Ingredient(name: "Зеленое масло", quantity: "по вкусу"),
                Ingredient(name: "Шпинат", quantity: "по вкусу")
            ],
            steps: [
                "Включаем духовку на 180°С.",
                "В миске соединяем готовое картофельное пюре, зеленое масло и шпинат (без жидкости). Хорошо перемешиваем.",
                "В форму для запекания выкладываем мясное рагу болоньезе, равномерно распределяя по дну.",
                "На рагу выкладываем картофельное пюре со шпинатом. Разравниваем ложкой так, чтобы образовалась вкусная корочка.",
                "Посыпаем всё сверху натертым сыром моцарелла.",
                "Ставим форму на противень и отправляем в разогретую духовку на 20 минут.",
                "После приготовления вынимаем из духовки и раскладываем по тарелкам."
            ],
            cookingTime: 40,
            views: 90,
            createdAt: Date(),
            category: "Популярные",
            isUserRecipe: false
        )
        
        let ratatouille = Recipe(
            id: "\(popularPrefix)2",
            title: "Рататуй",
            ingredients: [
                Ingredient(name: "Перец болгарский", quantity: "2 шт"),
                Ingredient(name: "Помидоры", quantity: "6 шт"),
                Ingredient(name: "Лук репчатый", quantity: "1 шт"),
                Ingredient(name: "Чеснок", quantity: "3 зубчика"),
                Ingredient(name: "Тимьян", quantity: "по вкусу"),
                Ingredient(name: "Лавровый лист", quantity: "по вкусу"),
                Ingredient(name: "Базилик", quantity: "по вкусу"),
                Ingredient(name: "Соль", quantity: "по вкусу"),
                Ingredient(name: "Перец", quantity: "по вкусу"),
                Ingredient(name: "Масло оливковое", quantity: "4 ст л"),
                Ingredient(name: "Цуккини", quantity: "1 шт"),
                Ingredient(name: "Кабачок", quantity: "1 шт"),
                Ingredient(name: "Баклажан", quantity: "1 шт")
            ],
            steps: [
                "Выкладываем в форму, в которой будет запекаться рататуй, сначала соус пеперад, а сверху него - порезанные кружочками овощи. Чередуйте их в любом порядке.",
                "Сверху нужно смазать оливковым маслом со специями, чесноком и зеленью.",
                "Накрываем крышкой или фольгой и отправляем в разогретую до 160-170 градусов духовку томиться примерно 1,5 часа, после этого снимаем фольгу или крышку и оставляем еще минут на 30 - смотрите по готовности. Сверху овощи должны немного прожариться."
            ],
            cookingTime: 40,
            views: 70,
            createdAt: Date(),
            category: "Популярные",
            isUserRecipe: false
        )

        // Genshin recipes
        let adeptusTemptationImageData = try? Data(contentsOf: Bundle.main.url(forResource: "2eda", withExtension: "png")!)
        let adeptusTemptation = Recipe(
            id: "\(genshinPrefix)1",
            title: "Искушение адепта",
            ingredients: [
                Ingredient(name: "Креветки", quantity: "300 г"),
                Ingredient(name: "Гребешки", quantity: "200 г"),
                Ingredient(name: "Лотос", quantity: "2 шт"),
                Ingredient(name: "Рисовое вино", quantity: "50 мл"),
                Ingredient(name: "Имбирь", quantity: "30 г"),
                Ingredient(name: "Зеленый лук", quantity: "2 стебля")
            ],
            steps: [
                "Очистите и промойте морепродукты.",
                "Нарежьте имбирь и зеленый лук.",
                "Разогрейте воду для приготовления на пару.",
                "Выложите морепродукты на лотос.",
                "Добавьте имбирь, лук и рисовое вино.",
                "Готовьте на пару 8 минут."
            ],
            cookingTime: 20,
            views: 85,
            createdAt: Date(),
            category: "Геншин",
            isUserRecipe: false,
            imageData: adeptusTemptationImageData
        )

        let goldenShrimp = Recipe(
            id: "\(genshinPrefix)2",
            title: "Золотые креветки",
            ingredients: [
                Ingredient(name: "Креветки", quantity: "400 г"),
                Ingredient(name: "Картофель", quantity: "2 шт"),
                Ingredient(name: "Сливки", quantity: "200 мл"),
                Ingredient(name: "Сыр", quantity: "100 г"),
                Ingredient(name: "Чеснок", quantity: "3 зубчика")
            ],
            steps: [
                "Очистите креветки и картофель.",
                "Нарежьте картофель тонкими ломтиками.",
                "Измельчите чеснок.",
                "Выложите слоями в форму картофель и креветки.",
                "Залейте сливками и посыпьте сыром.",
                "Запекайте при 180°C 25 минут."
            ],
            cookingTime: 35,
            views: 75,
            createdAt: Date(),
            category: "Геншин",
            isUserRecipe: false
        )

        // Ghibli recipes
        let spiritedAwaySushi = Recipe(
            id: "\(ghibliPrefix)1",
            title: "Суши родителей Тихиро",
            ingredients: [
                Ingredient(name: "Рис для суши", quantity: "2 стакана"),
                Ingredient(name: "Нори", quantity: "4 листа"),
                Ingredient(name: "Лосось", quantity: "200 г"),
                Ingredient(name: "Авокадо", quantity: "1 шт"),
                Ingredient(name: "Огурец", quantity: "1 шт"),
                Ingredient(name: "Рисовый уксус", quantity: "3 ст.л.")
            ],
            steps: [
                "Приготовьте рис для суши.",
                "Нарежьте лосось, авокадо и огурец.",
                "Выложите нори на бамбуковый коврик.",
                "Распределите рис по нори.",
                "Выложите начинку и сверните ролл.",
                "Нарежьте на порции."
            ],
            cookingTime: 45,
            views: 95,
            createdAt: Date(),
            category: "Гибли",
            isUserRecipe: false
        )

        let ponyoRamen = Recipe(
            id: "\(ghibliPrefix)2",
            title: "Рамен Поньо",
            ingredients: [
                Ingredient(name: "Лапша рамен", quantity: "200 г"),
                Ingredient(name: "Ветчина", quantity: "100 г"),
                Ingredient(name: "Яйцо", quantity: "2 шт"),
                Ingredient(name: "Зеленый лук", quantity: "2 стебля"),
                Ingredient(name: "Бульон", quantity: "1 л")
            ],
            steps: [
                "Вскипятите бульон.",
                "Отварите лапшу до готовности.",
                "Нарежьте ветчину и зеленый лук.",
                "Сварите яйца всмятку.",
                "Соберите рамен: лапша, бульон, ветчина, яйцо.",
                "Украсьте зеленым луком."
            ],
            cookingTime: 30,
            views: 88,
            createdAt: Date(),
            category: "Гибли",
            isUserRecipe: false
        )
        
        // Set the recipes array with consistent ordering
        popularRecipes = [
            // Хогвартс recipes with sequential IDs
            slivochnoePivo,    // hogwarts_1
            zharkoe,           // hogwarts_2
            yorkshirePudding,  // hogwarts_3
            // Популярные recipes with sequential IDs
            pastushiyPirog,    // popular_1
            ratatouille,       // popular_2
            // Геншин recipes with sequential IDs
            adeptusTemptation, // genshin_1
            goldenShrimp,      // genshin_2
            // Гибли recipes with sequential IDs
            spiritedAwaySushi, // ghibli_1
            ponyoRamen         // ghibli_2
        ]
    }
    
    private func setupFirestoreListener() {
        // Remove any existing listener
        listener?.remove()
        
        listener = db.collection("recipes")
            .whereField("isUserRecipe", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening to Firestore: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = querySnapshot else {
                    print("No documents in Firestore")
                    return
                }
                
                // Handle deleted documents
                snapshot.documentChanges.forEach { diff in
                    if diff.type == .removed {
                        DispatchQueue.main.async {
                            self.recipes.removeAll { $0.id == diff.document.documentID }
                        }
                    }
                }
                
                // Update recipes array with current data
                let newRecipes = snapshot.documents.compactMap { document -> Recipe? in
                    do {
                        var recipe = try document.data(as: Recipe.self)
                        recipe.id = document.documentID
                    return recipe
                    } catch {
                        print("Error decoding recipe: \(error)")
                        return nil
                    }
                }
                
                DispatchQueue.main.async {
                    self.recipes = newRecipes
                }
            }
    }
    
    func addRecipe(_ recipe: Recipe) {
        var newRecipe = recipe
        newRecipe.id = UUID().uuidString
        newRecipe.isUserRecipe = true
        newRecipe.createdAt = Date()
        
        do {
            // Convert recipe to dictionary
            let recipeData = try Firestore.Encoder().encode(newRecipe)
            
            // Save to Firestore
            db.collection("recipes").document(newRecipe.id!).setData(recipeData) { [weak self] error in
                if let error = error {
                    print("Error saving to Firestore: \(error.localizedDescription)")
                } else {
                    print("Recipe successfully saved to Firestore")
                    DispatchQueue.main.async {
                        self?.recipes.insert(newRecipe, at: 0)
                    }
                }
            }
        } catch {
            print("Error encoding recipe: \(error)")
        }
    }
    
    func updateRecipe(_ recipe: Recipe) {
        guard let id = recipe.id else {
            print("Ошибка обновления: отсутствует ID рецепта")
            return
        }
        
        var updatedRecipe = recipe
        updatedRecipe.isUserRecipe = true  // Ensure it's marked as a user recipe
        
        do {
            // Convert recipe to dictionary using Firestore.Encoder
            let recipeData = try Firestore.Encoder().encode(updatedRecipe)
            
            // Save to Firestore
            db.collection("recipes").document(id).setData(recipeData, merge: true) { [weak self] error in
                if let error = error {
                    print("Ошибка обновления: \(error.localizedDescription)")
                } else {
                    print("Рецепт успешно обновлен")
                    DispatchQueue.main.async {
                        if let index = self?.recipes.firstIndex(where: { $0.id == id }) {
                            self?.recipes[index] = updatedRecipe
                        } else {
                            // If not found in the array, add it
                            self?.recipes.append(updatedRecipe)
                        }
                    }
                }
            }
        } catch {
            print("Ошибка кодирования: \(error)")
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        guard let id = recipe.id else {
            print("Error: Recipe has no ID")
            return
        }
        
        // Delete from Firestore
        db.collection("recipes").document(id).delete { [weak self] error in
            if let error = error {
                print("Error deleting from Firestore: \(error.localizedDescription)")
            } else {
                print("Recipe successfully deleted from Firestore")
                // Only remove from local array after successful Firestore deletion
                DispatchQueue.main.async {
                    self?.recipes.removeAll { $0.id == id }
                }
            }
        }
    }
    
    func deleteRecipe(at offsets: IndexSet) {
        for index in offsets {
            if index < recipes.count {
                let recipe = recipes[index]
                deleteRecipe(recipe)
            }
        }
    }
    
    func markAsViewed(_ recipe: Recipe) {
        if !viewedRecipes.contains(where: { $0.id == recipe.id }) {
            viewedRecipes.append(recipe)
        }
    }
}

extension Recipe {
    func toFirestoreData() throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(self)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
}
