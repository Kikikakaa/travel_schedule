import Foundation
typealias ThreadStationsResponse = Components.Schemas.ThreadStationsResponse

@MainActor
final class ThreadStationsViewModel: ObservableObject {
    @Published var threadInfo: ThreadStationsResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: YandexRaspAPI
    private let fromCode: String

    init(api: YandexRaspAPI, from: String) {
        self.api = api
        self.fromCode = from
    }

    func loadThreadStations() async {
        isLoading = true
        errorMessage = nil
        do {
            let stationsResponse = try await api.getThreadStations(fromStationCode: fromCode)
            threadInfo = stationsResponse
        } catch {
            print("❌ Ошибка загрузки станций следования: \(error)")
            errorMessage = "Не удалось загрузить маршрут"
        }
        isLoading = false
    }
}
