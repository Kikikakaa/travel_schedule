import Foundation
import OpenAPIRuntime

@MainActor
final class CopyrightViewModel: ObservableObject {
    @Published var copyright: String = ""
    @Published var url: String = ""
    
    private let api: YandexRaspAPI
    
    init(api: YandexRaspAPI) {
        self.api = api
    }
    
    func load() {
        Task {
            do {
                let result = try await api.getCopyright()
                self.copyright = result.text ?? "Нет текста"
                self.url = result.url ?? ""
            } catch {
                print("❌ Ошибка загрузки авторских прав: \(error)")
            }
        }
    }
}
