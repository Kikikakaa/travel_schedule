import Foundation
import Combine

@MainActor
final class CitySearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var cities: [City] = []
    @Published private(set) var filtered: [City] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let locationService: LocationServiceProtocol
    let stationsVM: AllStationsViewModel

    private var didBuild = false

    init(stationsVM: AllStationsViewModel, locationService: LocationServiceProtocol) {
        self.stationsVM = stationsVM
        self.locationService = locationService

        $query
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.applyFilter(query: text)
            }
            .store(in: &cancellables)
    }

    func loadCities() {
        guard !didBuild else {
            print("⚠️ CitySearchViewModel: Already built, skipping")
            return
        }
        didBuild = true
        isLoading = true
        print("🔄 CitySearchViewModel: Starting loadCities...")

        Task {
            do {
                if !stationsVM.didLoad {
                    print("📡 CitySearchViewModel: Waiting for stationsVM.loadStations()")
                    await stationsVM.loadStations()
                    print("✅ CitySearchViewModel: stationsVM.loadStations() completed")
                }

                // Hardcode regionCode to bypass LocationService
                let regionCode = "RU"
                let currentCountryName = Locale.current.localizedString(forRegionCode: regionCode) ?? regionCode
                print("🌍 CitySearchViewModel: Using regionCode=\(regionCode), countryName=\(currentCountryName)")

                // Offload heavy processing to background
                let processedList = await Task.detached {
                    var byId = [String: City]()
                    var skippedCount = 0
                    var totalSettlements = 0

                    print("🔄 CitySearchViewModel: Starting settlement processing...")
                    for (countryIndex, country) in await self.stationsVM.countries.enumerated() {
                        let countryName = country.title ?? "Unknown"
                        for (regionIndex, region) in (country.regions ?? []).enumerated() {
                            for (settlementIndex, settlement) in (region.settlements ?? []).enumerated() {
                                totalSettlements += 1
                                guard let id = settlement.codes?.yandex_code, !id.isEmpty else {
                                    print("⚠️ Skipping settlement [\(countryIndex):\(regionIndex):\(settlementIndex)]: title=\(settlement.title ?? "nil"), yandex_code=\(settlement.codes?.yandex_code ?? "nil")")
                                    skippedCount += 1
                                    continue
                                }
                                let title = settlement.title ?? "Unknown_\(id)"
                                if byId[id] == nil {
                                    byId[id] = City(id: id, title: title, country: countryName)
                                }
                            }
                        }
                    }

                    var list = Array(byId.values)
                    print("🔄 CitySearchViewModel: Sorting \(list.count) cities...")
                    list.sort {
                        let lTop = $0.country == currentCountryName
                        let rTop = $1.country == currentCountryName
                        if lTop != rTop { return lTop }
                        return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                    }

                    print("✅ CitySearchViewModel: Processed \(list.count) cities, skipped \(skippedCount) of \(totalSettlements) settlements")
                    return list
                }.value

                // Update UI properties on main
                DispatchQueue.main.async {
                    self.cities = processedList
                    self.filtered = processedList
                    self.isLoading = false
                    print("🏁 CitySearchViewModel: Completed loading, isLoading = false, cities.count = \(processedList.count)")
                }
            } catch {
                print("❌ CitySearchViewModel: Error loading cities: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to load cities: \(error.localizedDescription)"
                }
            }
        }
    }

    private func applyFilter(query: String) {
        guard !cities.isEmpty else {
            print("🔍 CitySearchViewModel: Skipping filter, cities not yet loaded")
            return
        }
        let q = query
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !q.isEmpty else {
            filtered = cities
            print("🔍 CitySearchViewModel: Reset filter, filtered.count = \(cities.count)")
            return
        }

        filtered = cities.filter {
            $0.title
                .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                .contains(q)
        }
        print("🔍 CitySearchViewModel: Applied filter '\(q)', filtered.count = \(filtered.count)")
    }
}
