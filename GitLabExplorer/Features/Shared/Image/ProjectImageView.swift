import SwiftUI

struct ProjectImageView: View {
    let imageURL: URL?
    let aspectRatio: CGFloat
    let cornerRadius: CGFloat
    
    init(
        imageURL: URL?,
        aspectRatio: CGFloat = 16/9,
        cornerRadius: CGFloat = 8
    ) {
        self.imageURL = imageURL
        self.aspectRatio = aspectRatio
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        AsyncImageView.thumbnail(
            imageURL: imageURL,
            aspectRatio: aspectRatio
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack(spacing: 16) {
        ProjectImageView(
            imageURL: URL(string: "https://via.placeholder.com/300x200"),
            aspectRatio: 16/9,
            cornerRadius: 8
        )
        .frame(height: 120)
        
        ProjectImageView(
            imageURL: nil,
            aspectRatio: 4/3,
            cornerRadius: 12
        )
        .frame(height: 150)
    }
    .padding()
} 