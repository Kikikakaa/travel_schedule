import Foundation

actor DateFormatterCache {
    static let shared = DateFormatterCache()
    
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f
    }()
    
    func string(from date: Date) -> String {
        isoFormatter.string(from: date)
    }
}
