import SwiftUI

struct StationScheduleView: View {
    
    @StateObject private var viewModel: StationScheduleViewModel
    
    init(api: YandexRaspAPI, stationCode: String, date: Date? = nil) {
        _viewModel = StateObject(
            wrappedValue: StationScheduleViewModel(
                api: api,
                stationCode: stationCode,
                date: date
            )
        )
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Загружаем рейсы...")
                } else if let error = viewModel.errorMessage {
                    Text("Ошибка: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else if viewModel.trips.isEmpty {
                    Text("Нет рейсов")
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.trips, id: \.thread?.uid) { trip in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(trip.thread?.title ?? "Без названия")
                                    .font(.headline)
                                if let number = trip.thread?.number {
                                    Text("(\(number))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if let departure = trip.departure {
                                Text("Отправление: \(formatted(date: departure))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let carrier = trip.thread?.carrier?.title {
                                Text("Перевозчик: \(carrier)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Поезда из Мск")
            .onAppear {
                viewModel.loadSchedule()
            }
        }
    }
    
    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM, HH:mm"
        return formatter.string(from: date)
    }
}
