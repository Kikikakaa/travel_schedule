import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

protocol RouteSearchServiceProtocol {
    func getRoutes(from: String, to: String, transport: String?) async throws -> Components.Schemas.Segments
}

final class RouteSearchService: RouteSearchServiceProtocol, @unchecked Sendable {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getRoutes(from: String, to: String, transport: String? = nil) async throws -> Components.Schemas.Segments {
        let today = DateFormatterForYandex.request.string(from: Date())

        let response = try await client.getSchedualBetweenStations(
            .init(
                query: .init(
                    apikey: apikey,
                    from: from,
                    to: to,
                    format: "json",
                    date: today,
                    transport_types: transport,
                    limit: 20
                )
            )
        )

        switch response {
        case .ok(let result):
            return try result.body.json
        case .undocumented(let status, let data):
            var buffer = Data()
            if let body = data.body {
                for try await chunk in body {
                    buffer.append(contentsOf: chunk)
                }
            }
            let string = String(data: buffer, encoding: .utf8) ?? "нераспарсено"
            print("‼️ Undocumented (\(status)): \(string)")
            throw URLError(.badServerResponse)
        }
    }
}
