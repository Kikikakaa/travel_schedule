import OpenAPIRuntime
import Foundation
import OpenAPIURLSession

typealias NearestStations = Components.Schemas.Stations

protocol NearestStationsServiceProtocol {
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations
}

final class NearestStationsService: NearestStationsServiceProtocol, @unchecked Sendable {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getNearestStations(
        lat: Double,
        lng: Double,
        distance: Int
    ) async throws -> NearestStations {

        let response = try await client.getNearestStations(
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
        case .ok(let okResponse):
            do {
                return try okResponse.body.json
            } catch {
                print("‼️ Ошибка декодирования ответа NearestStations: \(error)")
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
            print("‼️ Неизвестный ответ NearestStations (\(status)): \(bodyText)")
            throw URLError(.badServerResponse)
        }
    }
}
