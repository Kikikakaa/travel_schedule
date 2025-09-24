import SwiftUI

struct ConnectionErrorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(.connectionError)
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)
                .accessibilityHidden(true)

            Text("нет интернета")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}

#Preview {
    ConnectionErrorView()
}
