import Foundation
import Combine

@MainActor
final class CitySearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var cities: [City] = []
    @Published private(set) var filtered: [City] = []
    @Published var isLoading: Bool = false

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
        guard !didBuild else { return }
        didBuild = true
        isLoading = true

        Task { @MainActor in
            defer { isLoading = false }

            if !stationsVM.didLoad {
                await stationsVM.loadStations()
            }

            let regionCode = (try? await locationService.currentCountryCode()) ?? "RU"
            let currentCountryName = Locale.current.localizedString(forRegionCode: regionCode) ?? regionCode

            var byId = [String: City]()

            for country in stationsVM.countries {
                let countryName = country.title ?? ""
                for region in country.regions ?? [] {
                    for settlement in region.settlements ?? [] {
                        guard
                            let id = settlement.codes?.yandex_code, !id.isEmpty,
                            let title = settlement.title, !title.isEmpty
                        else { continue }

                        if byId[id] == nil {
                            byId[id] = City(id: id, title: title, country: countryName)
                        }
                    }
                }
            }

            var list = Array(byId.values)
            list.sort {
                let lTop = $0.country == currentCountryName
                let rTop = $1.country == currentCountryName
                if lTop != rTop { return lTop }
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }

            self.cities = list
            self.filtered = list
        }
    }

    private func applyFilter(query: String) {
        let q = query
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !q.isEmpty else { filtered = cities; return }

        filtered = cities.filter {
            $0.title
                .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                .contains(q)
        }
    }
}
