import OpenAPIURLSession
import SwiftUI

struct NearestStationsView: View {
    @StateObject private var viewModel: NearestStationsViewModel

    init(api: YandexRaspAPI) {
        _viewModel = StateObject(wrappedValue: NearestStationsViewModel(api: api))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Ближайшие станции")
                .font(.title2)
                .bold()

            switch viewModel.state {
            case .idle:
                EmptyView()

            case .loading:
                ProgressView("Определяем местоположение...")

            case .loaded(let stations):
                if stations.isEmpty {
                    Text("Станции не найдены")
                } else {
                    List(stations, id: \.self) { station in
                        VStack(alignment: .leading) {
                            Text(station.title ?? "Без названия")
                                .font(.headline)
                            if let distance = station.distance {
                                Text("📍 \(String(format: "%.1f", distance)) км")
                                    .font(.subheadline)
                            }
                        }
                    }
                }

            case .noPermission:
                VStack(spacing: 8) {
                    Text("Разрешите доступ к геопозиции, чтобы увидеть ближайшие станции.")
                        .multilineTextAlignment(.center)
                    Button("Открыть настройки") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

            case .error(let message):
                Text("Ошибка: \(message)")
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
        .task {
            await viewModel.load()
        }
    }
}
