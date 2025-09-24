import OpenAPIRuntime

struct City: Identifiable, Hashable {
    let id: String
    let title: String
    let country: String
}

struct Price: Codable {
    let whole: Int
    let cents: Int
}

struct Pagination: Codable {
    let total: Int
    let limit: Int
    let offset: Int
}

struct ScheduleResponse: Codable {
    let search: SearchInfo
    let segments: [Segment]
    let intervalSegments: [Segment]
    let pagination: Pagination
}

struct SearchInfo: Codable {
    let from: Station
    let to: Station
    let date: String
}

struct Station: Codable {
    let code: String
    let title: String
    let stationType: String
    let transportType: String
}

struct StationSelection {
    var displayText: String = ""
    var isEmpty: Bool { displayText.isEmpty }
}


struct Segment: Codable {
    let thread: ThreadInfo
    let from: Station
    let to: Station
    let departure: String
    let arrival: String
    let duration: Double
    let ticketsInfo: TicketsInfo?
}

struct StationItem: Identifiable, Hashable {
    let id: String
    let title: String
    let transportType: String?
    let stationType: String?
}

struct TicketsInfo: Codable {
    let etMarker: Bool
    let places: [TicketPlace]
}

struct TicketPlace: Codable {
    let currency: String
    let price: Price
    let name: String
}

struct ThreadInfo: Codable {
    let number: String
    let title: String
    let transportType: String
}
