import SwiftUI

// MARK: - Models + Mock
struct SegmentItem: Identifiable, Hashable {
    let id: String
    let carrierName: String
    let carrierLogo: String?      // пока локальное имя картинки
    let departureDateShort: String
    let departureTime: String
    let arrivalTime: String
    let durationText: String
    let transferText: String?

    static let mock: [SegmentItem] = [
        .init(id: "1", carrierName: "РЖД", carrierLogo: "LogoStub1",
              departureDateShort: "14 января", departureTime: "22:30", arrivalTime: "08:15",
              durationText: "20 часов", transferText: "С пересадкой в Костроме"),
        .init(id: "2", carrierName: "ФГК", carrierLogo: "LogoStub2",
              departureDateShort: "15 января", departureTime: "01:15", arrivalTime: "09:00",
              durationText: "9 часов", transferText: nil),
        .init(id: "3", carrierName: "Урал логистика", carrierLogo: "LogoStub3",
              departureDateShort: "16 января", departureTime: "12:30", arrivalTime: "21:00",
              durationText: "9 часов", transferText: nil),
    ]
}

// MARK: - Placeholder
struct ContentPlaceholder: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage).font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(title).font(.headline)
            Text(subtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    ResultsView(from: "Москва (Ярославский вокзал)", to: "Санкт-Петербург (Балтийский вокзал)")
}
