import Foundation
import Combine

@MainActor
final class StationScheduleViewModel: ObservableObject {
    @Published var trips: [Components.Schemas.Schedule] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var didLoad = false
    
    private let api: YandexRaspAPI
    private let stationCode: String
    private let date: Date?
    private var cancellables = Set<AnyCancellable>()
    
    init(api: YandexRaspAPI, stationCode: String, date: Date? = nil) {
        self.api = api
        self.stationCode = stationCode
        self.date = date
    }
    
    func loadSchedule() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await api.getStationSchedule(
                    station: stationCode,
                    date: date
                )
                self.trips = response
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

