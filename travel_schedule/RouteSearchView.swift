import SwiftUI
import OpenAPIURLSession
import OpenAPIRuntime

struct RouteSearchView: View {
    @State private var isLoading = false
    @State private var segments: [Components.Schemas.Segment] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Поиск маршрута")
                .font(.title)
                .bold()

            VStack(alignment: .leading, spacing: 4) {
                Text("Параметры запроса:")
                    .font(.subheadline)
                    .bold()
                Text("Маршрут: Москва (Шереметьево) → Екатеринбург (Кольцово)")
                Text("Дата (текущая): \(DateFormatter.ddMMyyyy.string(from: Date()))")
                Text("Тип транспорта: Самолёт ✈️")
                Text("Лимит: 10 рейсов")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            if isLoading {
                ProgressView("Загружаем маршруты...")
            } else if let errorMessage {
                Text("Ошибка: \(errorMessage)")
                    .foregroundColor(.red)
            } else if segments.isEmpty {
                Text("Нет данных для отображения")
            } else {
                List(segments, id: \.self) { segment in
                    VStack(alignment: .leading, spacing: 4) {
                        if let fromTitle = segment.from?.title,
                           let toTitle = segment.to?.title {
                            Text("\(fromTitle) → \(toTitle)")
                                .font(.headline)
                        }

                        if let departure = segment.departure {
                            Text("Отправление: \(formatDate(departure))")
                        }
                        
                        
                        if let arrival = segment.arrival {
                            Text("Прибытие: \(formatDate(arrival))")
                        }

                        if let title = segment.thread?.title {
                            Text("Маршрут: \(title)")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                await loadRoute()
            }
        }
    }

    private func loadRoute() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let client = Client(
                serverURL: URL(string: "https://api.rasp.yandex.net")!,
                transport: URLSessionTransport()
            )
            let api = YandexRaspAPI(client: client, apikey: API.key)

            let result = try await api.searchRoutes(
                from: "s9600213", // Москва
                to: "s9600370"    // Екатеринбург
            )

            segments = result.segments ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
