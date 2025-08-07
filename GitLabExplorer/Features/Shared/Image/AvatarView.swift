import SwiftUI

struct AvatarView: View {
    let imageURL: URL?
    let size: CGFloat
    let placeholder: String
    
    init(imageURL: URL?, size: CGFloat = 40, placeholder: String = "👤") {
        self.imageURL = imageURL
        self.size = size
        self.placeholder = placeholder
    }
    
    var body: some View {
        AsyncImageView.avatar(
            imageURL: imageURL,
            size: size,
            placeholder: placeholder
        )
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

#Preview {
    VStack(spacing: 20) {
        AvatarView(
            imageURL: URL(string: "https://gitlab.com/uploads/-/system/user/avatar/1/avatar.png"),
            size: 60,
            placeholder: "👤"
        )
        
        AvatarView(
            imageURL: nil,
            size: 40,
            placeholder: "👤"
        )
        
        AvatarView(
            imageURL: URL(string: "https://via.placeholder.com/100x100"),
            size: 80,
            placeholder: "👤"
        )
    }
    .padding()
} 