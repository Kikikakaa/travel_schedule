import SwiftUI

struct SettingsScreen: View {
    @State private var showConnectionError = false
    @State private var showServerError = false

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image("Settings").renderingMode(.template)
                    .font(.system(size: 36))
                    .foregroundColor(.ypBlack)
                Text("Настройки")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.ypBlack)
            }
            .foregroundStyle(.secondary)

            VStack(spacing: 20) {
                Button("нет интернета") {
                    showConnectionError = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .foregroundColor(.white)
                
                Button("ошибка сервера") {
                    showServerError = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .foregroundColor(.white)
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showConnectionError) {
            ConnectionErrorView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showServerError) {
            ServerErrorView()
                .presentationDragIndicator(.visible)
        }
    }
}
#Preview {
    SettingsScreen()
}
