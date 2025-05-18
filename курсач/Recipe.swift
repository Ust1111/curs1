import Foundation
import UIKit

struct Ingredient: Codable, Identifiable {
    var id = UUID()
    var name: String
    var quantity: String
}

struct Recipe: Identifiable, Hashable, Codable {
    var id: String?  // Firestore ID
    let localId: UUID // For Identifiable conformance
    var title: String
    var ingredients: [Ingredient]
    var steps: [String]
    var cookingTime: Int
    var views: Int
    var createdAt: Date
    var category: String?
    var isUserRecipe: Bool
    var imageData: Data?

    init(
        id: String? = nil,
        title: String,
        ingredients: [Ingredient],
        steps: [String],
        cookingTime: Int,
        views: Int = 0,
        createdAt: Date = Date(),
        category: String? = nil,
        isUserRecipe: Bool = false,
        imageData: Data? = nil
    ) {
        self.id = id
        self.localId = UUID()
        self.title = title
        self.ingredients = ingredients
        self.steps = steps
        self.cookingTime = cookingTime
        self.views = views
        self.createdAt = createdAt
        self.category = category
        self.isUserRecipe = isUserRecipe
        self.imageData = imageData
    }
    
    // For Identifiable conformance
    var identifier: UUID { localId }

    // Преобразование в base64
    var imageBase64: String? {
        get { imageData?.base64EncodedString() }
        set {
            if let base64 = newValue {
                imageData = Data(base64Encoded: base64)
            } else {
                imageData = nil
            }
        }
    }

    // Явно указываем, какие поля кодировать
    enum CodingKeys: String, CodingKey {
        case id
        case localId
        case title
        case ingredients
        case steps
        case cookingTime
        case views
        case createdAt
        case category
        case isUserRecipe
        case imageBase64
    }

    // Вручную реализуем Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.localId = try container.decodeIfPresent(UUID.self, forKey: .localId) ?? UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        self.steps = try container.decode([String].self, forKey: .steps)
        self.cookingTime = try container.decode(Int.self, forKey: .cookingTime)
        self.views = try container.decode(Int.self, forKey: .views)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.isUserRecipe = try container.decode(Bool.self, forKey: .isUserRecipe)

        let imageBase64 = try container.decodeIfPresent(String.self, forKey: .imageBase64)
        self.imageData = imageBase64 != nil ? Data(base64Encoded: imageBase64!) : nil
    }

    // Вручную реализуем Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(localId, forKey: .localId)
        try container.encode(title, forKey: .title)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(steps, forKey: .steps)
        try container.encode(cookingTime, forKey: .cookingTime)
        try container.encode(views, forKey: .views)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encode(isUserRecipe, forKey: .isUserRecipe)
        try container.encodeIfPresent(imageBase64, forKey: .imageBase64)
    }

    // Hashable
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id && lhs.localId == rhs.localId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(localId)
    }
}
