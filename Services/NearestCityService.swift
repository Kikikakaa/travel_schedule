import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

protocol NearestCityServiceProtocol {
    func getNearestCity(lat: Double, lng: Double, distance: Int) async throws -> Components.Schemas.NearestCityResponse
}

final class NearestCityService: NearestCityServiceProtocol, @unchecked Sendable {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getNearestCity(
        lat: Double,
        lng: Double,
        distance: Int
    ) async throws -> Components.Schemas.NearestCityResponse {

        let response = try await client.getNearestCity(
            .init(
                query: .init(
                    apikey: apikey,
                    lat: lat,
                    lng: lng,
                    distance: distance,
                    lang: "ru_RU",
                    format: "json"
                )
            )
        )

        switch response {
        case .ok(let result):
            do {
                let city = try result.body.json
                return city
            } catch {
                print("‼️ Ошибка декодирования ответа NearestCity: \(error)")
                throw URLError(.cannotDecodeContentData)
            }

        case .undocumented(let status, let data):
            var buffer = Data()
            if let body = data.body {
                for try await chunk in body {
                    buffer.append(contentsOf: chunk)
                }
            }
            let bodyText = String(data: buffer, encoding: .utf8) ?? "unknown"
            print("‼️ Неизвестный ответ NearestCity (\(status)): \(bodyText)")
            throw URLError(.badServerResponse)
        }
    }
}
