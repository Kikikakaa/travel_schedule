import SwiftUI

class ResultsViewModel: ObservableObject {
    @Published var showFilters = false
    @Published var items: [SegmentItem] = []
    @Published var isLoading = false
    @Published var showConnectionError = false
    @Published var showServerError = false
    @Published var filtersApplied = false
    @Published var selectedItem: SegmentItem?
    
    private var allItems: [SegmentItem] = []
    private var currentFilters: Filters?
    private var didLoad = false
    private let fromCode: String
    private let toCode: String
    let api: YandexRaspAPIProtocol
    
    init(api: YandexRaspAPIProtocol, fromCode: String, toCode: String) {
        self.api = api
        self.fromCode = fromCode
        self.toCode = toCode
    }
    
    func loadIfNeeded() {
        if !didLoad {
            didLoad = true
            load()
        } else if currentFilters != nil {
            applyFilters(currentFilters!)
        }
    }
    
    func applyFilters(_ filters: Filters) {
        currentFilters = filters
        filtersApplied = !(filters.morning == false &&
                           filters.dayTime == false &&
                           filters.evening == false &&
                           filters.night == false &&
                           filters.transfers == nil)
        
        guard let filters = currentFilters else {
            items = sortByDeparture(allItems)
            return
        }
        
        let filtered = allItems.filter { item in
            if filters.morning || filters.dayTime || filters.evening || filters.night {
                guard let dep = timeFormatter.date(from: item.departureTime) else { return false }
                let hour = Calendar.current.component(.hour, from: dep)
                var ok = false
                if filters.morning, (6..<12).contains(hour) { ok = true }
                if filters.dayTime, (12..<18).contains(hour) { ok = true }
                if filters.evening, (18..<24).contains(hour) { ok = true }
                if filters.night, (0..<6).contains(hour) { ok = true }
                if !ok { return false }
            }
            
            if let needTransfers = filters.transfers {
                if item.hasTransfers != needTransfers {
                    return false
                }
            }
            return true
        }
        
        items = sortByDeparture(filtered)
    }
    
    private func load() {
        isLoading = true
        
        Task {
            do {
                let segments = try await api.searchRoutes(from: fromCode, to: toCode)
                let mapped = (segments.segments ?? []).compactMap { SegmentItem(from: $0) }
                
                await MainActor.run {
                    self.allItems = mapped
                    if currentFilters != nil {
                        self.applyFilters(currentFilters!)
                    } else {
                        self.items = sortByDeparture(mapped)
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet, .timedOut, .cannotFindHost, .cannotConnectToHost:
                            self.showConnectionError = true
                        default:
                            self.showServerError = true
                        }
                    } else {
                        self.showServerError = true
                    }
                }
            }
        }
    }
    
    private func sortByDeparture(_ array: [SegmentItem]) -> [SegmentItem] {
        array.sorted {
            (timeFormatter.date(from: $0.departureTime) ?? .distantPast) <
            (timeFormatter.date(from: $1.departureTime) ?? .distantPast)
        }
    }
}

fileprivate let timeFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    f.timeZone = TimeZone.current
    f.locale = Locale(identifier: "ru_RU")
    return f
}()
