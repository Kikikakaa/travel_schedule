import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

protocol CopyrightServiceProtocol {
    func getCopyright() async throws -> Components.Schemas.Copyright
}

final class CopyrightService: CopyrightServiceProtocol, @unchecked Sendable {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getCopyright() async throws -> Components.Schemas.Copyright {
        let input = Operations.getCopyright.Input(
            query: .init(apikey: apikey)
        )
        
        let response = try await client.getCopyright(input)
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let copyrightResponse):
                guard let copyright = copyrightResponse.copyright else {
                    throw URLError(.badServerResponse)
                }
                return copyright
            }
        default:
            throw URLError(.badServerResponse)
        }
    }
}




