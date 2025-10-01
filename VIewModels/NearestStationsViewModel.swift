import Foundation
import CoreLocation

@MainActor
final class NearestStationsViewModel: ObservableObject {
    @Published var state: LoadableState<[Components.Schemas.Station]> = .idle

    private let api: YandexRaspAPI
    private let locationService: LocationServiceProtocol

    init(api: YandexRaspAPI, locationService: LocationServiceProtocol = LocationService()) {
        self.api = api
        self.locationService = locationService
    }

    func load() async {
        state = .loading
        do {
            let location = try await locationService.requestCurrentLocation()
            print("📍 Локация: \(location.latitude), \(location.longitude)")

            let stations = try await api.getNearestStations(
                lat: location.latitude,
                lon: location.longitude,
                distance: 50
            )

            print("✅ Найдено станций: \(stations.count)")
            state = .loaded(stations)
        } catch {
            let nsError = error as NSError
            if nsError.code == 1 {
                state = .noPermission
            } else {
                state = .error(error.localizedDescription)
            }
            print("❌ Ошибка получения станций: \(error)")
        }
    }
}
