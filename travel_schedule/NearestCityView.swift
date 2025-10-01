import SwiftUI
import CoreLocation
import OpenAPIURLSession

struct NearestCityView: View {
    @State private var state: LoadableState<Components.Schemas.NearestCityResponse> = .idle

    let api: YandexRaspAPI
    let locationService: LocationServiceProtocol

    var body: some View {
        VStack(spacing: 16) {
            Text("Ближайший город")
                .font(.title2)
                .bold()

            content

            Spacer()
        }
        .padding()
        .onAppear {
            Task { await loadNearestCity() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .idle:
            EmptyView()

        case .loading:
            ProgressView("Определяем местоположение...")

        case .loaded(let city):
            VStack(alignment: .leading, spacing: 8) {
                Text("🏙️ \(city.title ?? "Неизвестно")")
                    .font(.title3)

                if let distance = city.distance {
                    Text("📍 Расстояние: \(String(format: "%.1f", distance)) км")
                } else {
                    Text("📍 Расстояние: неизвестно")
                }

                if let lat = city.lat, let lng = city.lng {
                    Text("🧭 Координаты: \(lat), \(lng)")
                } else {
                    Text("🧭 Координаты: неизвестны")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)

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
            .padding()

        case .error(let message):
            Text("Ошибка: \(message)")
                .foregroundColor(.red)
        }
    }

    private func loadNearestCity() async {
        state = .loading

        do {
            let coordinate = try await locationService.requestCurrentLocation()
            let result = try await api.getNearestCity(
                lat: coordinate.latitude,
                lon: coordinate.longitude,
                distance: 50
            )
            state = .loaded(result)
        } catch {
            if (error as NSError).code == 1 {
                state = .noPermission
            } else {
                state = .error(error.localizedDescription)
            }
        }
    }
}
