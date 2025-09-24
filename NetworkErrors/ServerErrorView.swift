import SwiftUI

struct ServerErrorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(.serverError)
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)
                .accessibilityHidden(true)

            Text("ошибка сервера")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}

#Preview {
    ServerErrorView()
}
