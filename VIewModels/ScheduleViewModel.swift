import Foundation
import Combine

@MainActor
final class ScheduleViewModel: ObservableObject {
    // MARK: - Published
    @Published var from = StationSelection()
    @Published var to   = StationSelection()
    
    @Published var viewedStories: Set<Int> = []
    @Published var currentStoryIndex: Int?
    @Published var showStory = false
    
    @Published var showFromSearch = false
    @Published var showToSearch = false
    
    // Derived state
    @Published private(set) var canSearch = false
    
    // MARK: - Data
    let stories: [Stories] = [.story1, .story2, .story3, .story4, .story5, .story6]
    
    let stationsVM: AllStationsViewModel
    let api: YandexRaspAPIProtocol
    let locationService: LocationServiceProtocol
    
    // MARK: - Init
    init(api: YandexRaspAPIProtocol) {
        self.api = api
        self.locationService = LocationService()
        self.stationsVM = AllStationsViewModel(api: api)
        
        // автообновление canSearch
        $from.combineLatest($to)
            .map { !$0.isEmpty && !$1.isEmpty }
            .assign(to: &$canSearch)
    }
    
    // MARK: - Actions
    func swapStations() {
        swap(&from, &to)
    }
    
    func openStory(at index: Int) {
        viewedStories.insert(index)
        currentStoryIndex = index
        showStory = true
    }
    
    func closeStory() {
        showStory = false
        currentStoryIndex = nil
    }
    
    // MARK: - Lifecycle
    func loadInitialData() async throws {
        let loc = try await locationService.requestCurrentLocation()
        let settlement = try await api.getNearestCity(
            lat: loc.latitude,
            lon: loc.longitude,
            distance: 50
        )
        print("🏙️ Nearest settlement: \(String(describing: settlement.title))")
    }
}
