import SwiftUI

// MARK: - Models + Mock
struct SegmentItem: Identifiable, Hashable {
    let id: String
    let carrierName: String
    let carrierCode: String
    let carrierLogo: String?
    let departureDateShort: String
    let departureTime: String
    let arrivalTime: String
    let durationText: String
    let transferText: String?
    let hasTransfers: Bool?
    let carrierCodes: Components.Schemas.Carrier
    let transportType: String?
}


// MARK: - Placeholder
struct ContentPlaceholder: View {

    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title).font(.system(size: 24, weight: .bold))
        }
        .padding()
    }
}
