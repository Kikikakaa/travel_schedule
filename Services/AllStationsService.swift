import OpenAPIURLSession
import OpenAPIRuntime
import Foundation

typealias AllStations = Components.Schemas.AllStationsResponse

protocol AllStationsServiceProtocol {
    func getAllStations() async throws -> AllStations
}

final class AllStationsService: AllStationsServiceProtocol, @unchecked Sendable {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    func getAllStations() async throws -> AllStations {
        let response = try await client.getAllStations(
            .init(
                query: .init(apikey: apikey),
                headers: .init(
                    accept: [
                        .init(contentType: .init(rawValue: "text/html")!)
                    ]
                )
            )
        )

        switch response {
        case .ok(let result):
            var fullData = Data()

            for try await chunk in try result.body.text_html_charset_utf_hyphen_8 {
                fullData.append(contentsOf: chunk)
            }

            let allStations = try JSONDecoder().decode(AllStations.self, from: fullData)
            return allStations

        case .undocumented(let status, let data):
            var buffer = Data()
            if let body = data.body {
                for try await chunk in body {
                    buffer.append(contentsOf: chunk)
                }
            }
            let errorText = String(data: buffer, encoding: .utf8) ?? "unknown"
            print("‼️ Undocumented (\(status)): \(errorText)")
            throw URLError(.badServerResponse)
        }
    }
}
