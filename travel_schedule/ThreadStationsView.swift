import SwiftUI

struct ThreadStationsView: View {
    @StateObject private var viewModel: ThreadStationsViewModel
    
    init(api: YandexRaspAPI, from: String) {
        _viewModel = StateObject(wrappedValue: ThreadStationsViewModel(api: api, from: from))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 🔹 Заголовок экрана
            Text("Станции следования")
                .font(.title)
                .bold()
            
            // 🔹 Параметры запроса
            if let info = viewModel.threadInfo {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Параметры запроса:")
                        .font(.subheadline)
                        .bold()
                    
                    if let title = info.title {
                        Text("Маршрут: \(title)")
                    }
                    Text("Тип транспорта: поезд")
                }
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
            
            // 🔹 Содержимое
            List {
                content
            }
        }
        .padding()
        .task {
            if viewModel.threadInfo == nil && !viewModel.isLoading {
                await viewModel.loadThreadStations()
            }
        }
    }
}

// MARK: - View Content
private extension ThreadStationsView {
    @ViewBuilder
    var content: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.errorMessage {
            errorView(error)
        } else if let stops = viewModel.threadInfo?.stops, !stops.isEmpty {
            stopsList(stops)
        } else {
            emptyView
        }
    }
    
    var loadingView: some View {
        ProgressView("Загрузка маршрута…")
    }
    
    func errorView(_ error: String) -> some View {
        Text(error)
            .foregroundColor(.red)
    }
    
    func stopsList(_ stops: [Components.Schemas.Stop]) -> some View {
        ForEach(stops, id: \.station?.code) { stop in
            if let station = stop.station {
                VStack(alignment: .leading, spacing: 4) {
                    Text(station.title ?? "Без названия")
                        .font(.headline)
                    
                    if let arrival = stop.arrival {
                        let isoString = ISO8601DateFormatter().string(from: arrival)
                        timeRow(label: "Прибытие", isoString: isoString)
                    }
                    
                    if let departure = stop.departure {
                        let isoString = ISO8601DateFormatter().string(from: departure)
                        timeRow(label: "Отправление", isoString: isoString)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    func timeRow(label: String, isoString: String) -> some View {
        var timeText = isoString
        
        if let date = DateFormatterForYandex.fullDateTime.date(from: isoString) {
            timeText = DateFormatterForYandex.time.string(from: date)
        }
        
        return Text("\(label): \(timeText)")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var emptyView: some View {
        Text("Нет данных о маршруте")
            .foregroundColor(.gray)
    }
}
