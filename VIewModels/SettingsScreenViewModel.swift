import SwiftUI

@MainActor
final class SettingsScreenViewModel: ObservableObject {
    // Хранимое свойство для темы
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    // Управление состоянием перехода
    @Published var showAgreement: Bool = false
    
    // Метод для открытия пользовательского соглашения
    func openAgreement() {
        showAgreement = true
    }
}
