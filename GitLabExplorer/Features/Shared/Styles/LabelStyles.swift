import SwiftUI

struct CustomSpacingLabelStyle: LabelStyle {
    var spacing: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}

extension Label {
    func tightSpacing(_ spacing: CGFloat = 4) -> some View {
        self.labelStyle(CustomSpacingLabelStyle(spacing: spacing))
    }
} 