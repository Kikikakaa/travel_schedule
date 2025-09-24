import Foundation
import Combine

@MainActor
final class AllStationsViewModel: ObservableObject {
    typealias Country = Components.Schemas.Country
    typealias Region = Components.Schemas.Region
    typealias Settlement = Components.Schemas.Settlement
    typealias Station = Components.Schemas.Station

    @Published var countries: [Country] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private(set) var didLoad = false

    private let service: YandexRaspServiceProtocol
    
    init(service: YandexRaspServiceProtocol) {
        self.service = service
    }

    func loadStations() async {
        guard !didLoad else {
            print("⚠️ AllStationsViewModel: уже загружено, пропускаем")
            return
        }
        didLoad = true

        print("🔄 AllStationsViewModel: начинаем загрузку...")
        isLoading = true
        errorMessage = nil

        do {
            // Offload API call and processing to background
            let processedCountries = try await Task.detached {
                print("📡 AllStationsViewModel: вызываем service.getAllStations()")
                let response = try await self.service.getAllStations()
                print("✅ AllStationsViewModel: получили ответ с \(response.countries?.count ?? 0) странами")
                
                let sortedCountries = (response.countries ?? [])
                    .sorted { ($0.title ?? "") < ($1.title ?? "") }
                    .map { country in
                        var sortedCountry = country
                        // Optionally add deeper sorting if needed (like in AllStationsViewModel)
                        sortedCountry.regions = country.regions?
                            .sorted { ($0.title ?? "") < ($1.title ?? "") }
                            .map { region in
                                var sortedRegion = region
                                sortedRegion.settlements = region.settlements?
                                    .sorted { ($0.title ?? "") < ($1.title ?? "") }
                                    .map { settlement in
                                        var sortedSettlement = settlement
                                        sortedSettlement.stations = settlement.stations?
                                            .sorted { ($0.title ?? "") < ($1.title ?? "") }
                                        return sortedSettlement
                                    }
                                return sortedRegion
                            }
                        return sortedCountry
                    }
                
                print("📊 AllStationsViewModel: обработали \(sortedCountries.count) стран")
                return sortedCountries
            }.value

            // Update UI on main
            DispatchQueue.main.async {
                self.countries = processedCountries
                self.isLoading = false
                print("🏁 AllStationsViewModel: завершаем загрузку, isLoading = false")
            }
        } catch {
            print("❌ AllStationsViewModel: ошибка - \(error)")
            DispatchQueue.main.async {
                self.errorMessage = "Не удалось загрузить станции"
                self.isLoading = false
            }
        }
    }
}

extension AllStationsViewModel {
    func stations(forCityCode cityCode: String) -> [StationItem] {
        let settlements = countries
            .flatMap { $0.regions ?? [] }
            .flatMap { $0.settlements ?? [] }
            .filter { $0.codes?.yandex_code == cityCode }

        let items = settlements
            .flatMap { $0.stations ?? [] }
            .compactMap { st -> StationItem? in
                guard let code = st.codes?.yandex_code, let title = st.title else { return nil }
                return StationItem(
                    id: code,
                    title: title,
                    transportType: st.transport_type,
                    stationType: st.station_type
                )
            }

        return items.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }
}
