import Foundation
import OpenAPIRuntime

final class CopyrightViewModel: ObservableObject {
    @Published var copyright: String = ""
    @Published var url: String = ""
    
    private let service: YandexRaspServiceProtocol
    
    init(service: YandexRaspServiceProtocol) {
        self.service = service
    }
    
    func load() {
        Task {
            do {
                let result = try await service.getCopyright()
                await MainActor.run {
                    self.copyright = result.copyright?.text ?? "Нет текста"
                    self.url = result.copyright?.url ?? ""
                }
            } catch {
                print("❌ Ошибка загрузки авторских прав: \(error)")
            }
        }
    }
}
