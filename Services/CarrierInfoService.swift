import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol CarrierInfoServiceProtocol {
    func getCarrierInfo(code: String, system: String?) async throws -> Components.Schemas.CarrierResponse
}


final class CarrierInfoService: CarrierInfoServiceProtocol, @unchecked Sendable {
    
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getCarrierInfo(code: String, system: String? = "iata") async throws -> Components.Schemas.CarrierResponse {
        let response = try await client.getCarrierInfo(
            .init(
                query: .init(
                    apikey: apikey,
                    code: code,
                    system: system,
                    lang: "ru_RU",
                    format: "json"
                )
            )
        )

        switch response {
        case .ok(let result):
            let decoded = try result.body.json
            print("✅ Распарсили: \(decoded)")
            return decoded

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
