import SwiftUI

enum AppError: Identifiable {
    var id: String { UUID().uuidString }
    
    case connection
    case server
}

struct ErrorView: View {
    let error: AppError

    var body: some View {
        VStack(spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)
                .accessibilityHidden(true)

            Text(message)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }

    private var imageName: String {
        switch error {
        case .connection: "connectionError"
        case .server: "serverError"
        }
    }

    private var message: String {
        switch error {
        case .connection: "нет интернета"
        case .server: "ошибка сервера"
        }
    }
}
