import SwiftUI

struct RecipeCardView: View {
    var recipe: Recipe
    var onViewTapped: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image section
            if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(10)
                
                // Content for cards with images
                VStack(alignment: .leading, spacing: 6) {
                    // Title section
                    Text(recipe.title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Info row
                    HStack(spacing: 12) {
                        // Cooking time
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            Text("\(recipe.cookingTime) мин")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Category if exists
                        if let category = recipe.category {
                            Text("•")
                                .foregroundColor(.gray)
                            Text(category)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
            }

                    // Ingredients preview (shorter for cards with images)
                    if !recipe.ingredients.isEmpty {
                        Text("Ингредиенты: " + recipe.ingredients.prefix(2).map { $0.name }.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        
                        if recipe.ingredients.count > 2 {
                            Text("и ещё \(recipe.ingredients.count - 2)...")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // View recipe button
                    Button(action: onViewTapped) {
                        Text("Посмотреть рецепт")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            } else {
                // Content for cards without images
                VStack(alignment: .leading, spacing: 8) {
                    // Title section
                    Text(recipe.title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Info row
                    HStack(spacing: 12) {
                        // Cooking time
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            Text("\(recipe.cookingTime) мин")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Category if exists
                        if let category = recipe.category {
                            Text("•")
                                .foregroundColor(.gray)
                            Text(category)
                .font(.subheadline)
                .foregroundColor(.gray)
                        }
                    }
            
                    // Ingredients preview
                    if !recipe.ingredients.isEmpty {
            Text("Ингредиенты:")
                .font(.subheadline)
                .bold()
            
                ForEach(recipe.ingredients.prefix(3), id: \.id) { ingredient in
                    Text("• \(ingredient.name): \(ingredient.quantity)")
                        .font(.subheadline)
                                .foregroundColor(.gray)
                        .lineLimit(1)
                }
                        
                if recipe.ingredients.count > 3 {
                    Text("и ещё \(recipe.ingredients.count - 3)...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
                    
                    // Steps preview
                    if !recipe.steps.isEmpty {
                        Text("Шаги:")
                            .font(.subheadline)
                            .bold()
                            .padding(.top, 4)
                        
                        ForEach(recipe.steps.prefix(2).indices, id: \.self) { index in
                            Text("\(index + 1). \(recipe.steps[index])")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                        
                        if recipe.steps.count > 2 {
                            Text("и ещё \(recipe.steps.count - 2) шагов...")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
            Spacer()
                    
                    // View recipe button
            Button(action: onViewTapped) {
                Text("Посмотреть рецепт")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .frame(width: 300, height: 380)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color.black.opacity(0.1)))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
