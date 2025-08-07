import SwiftUI
import Kingfisher

struct AsyncImageView: View {
    let imageURL: URL?
    let placeholder: AnyView
    let contentMode: SwiftUI.ContentMode
    let onFailure: ((Error) -> Void)?
    
    init(
        imageURL: URL?,
        placeholder: AnyView = AnyView(
            Rectangle()
                .fill(Color.gray.opacity(0.3))
        ),
        contentMode: SwiftUI.ContentMode = .fill,
        onFailure: ((Error) -> Void)? = nil
    ) {
        self.imageURL = imageURL
        self.placeholder = placeholder
        self.contentMode = contentMode
        self.onFailure = onFailure
    }
    
    var body: some View {
        if let imageURL = imageURL {
            KFImage(imageURL)
                .placeholder {
                    placeholder
                }
                .onFailure { error in
                    onFailure?(error)
                    print("Failed to load image: \(error)")
                }
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            placeholder
        }
    }
}

// MARK: - Convenience Initializers
extension AsyncImageView {
    /// For avatar/profile images
    static func avatar(
        imageURL: URL?,
        size: CGFloat = 40,
        placeholder: String = "👤"
    ) -> AsyncImageView {
        AsyncImageView(
            imageURL: imageURL,
            placeholder: AnyView(
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text(placeholder)
                            .font(.system(size: size * 0.4))
                            .foregroundColor(.gray)
                    )
            )
        )
    }
    
    /// For project/thumbnail images
    static func thumbnail(
        imageURL: URL?,
        aspectRatio: CGFloat = 16/9
    ) -> AsyncImageView {
        AsyncImageView(
            imageURL: imageURL,
            placeholder: AnyView(
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.gray)
                    )
            ),
            contentMode: .fit
        )
    }
    
    /// For full-size images
    static func fullSize(
        imageURL: URL?,
        aspectRatio: CGFloat? = nil
    ) -> AsyncImageView {
        AsyncImageView(
            imageURL: imageURL,
            placeholder: AnyView(
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    )
            ),
            contentMode: aspectRatio != nil ? SwiftUI.ContentMode.fit : SwiftUI.ContentMode.fill
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        // Avatar example
        AsyncImageView.avatar(
            imageURL: URL(string: "https://gitlab.com/uploads/-/system/user/avatar/1/avatar.png"),
            size: 60
        )
        .frame(width: 60, height: 60)
        .clipShape(Circle())
        
        // Thumbnail example
        AsyncImageView.thumbnail(
            imageURL: URL(string: "https://via.placeholder.com/300x200")
        )
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        
        // Full size example
        AsyncImageView.fullSize(
            imageURL: URL(string: "https://via.placeholder.com/400x300")
        )
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
} 
