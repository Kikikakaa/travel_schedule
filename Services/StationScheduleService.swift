import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol StationScheduleServiceProtocol {
    func getStationSchedule(station: String, date: Date?, transport: String?) async throws -> Components.Schemas.ScheduleResponse
}

final class StationScheduleService: StationScheduleServiceProtocol {
    private let client: Client
    private let apikey: String

    
    init(client: Client, apikey: String) {
            self.client = client
            self.apikey = apikey
        }
        
        func getStationSchedule(
            station: String,
            date: Date? = nil,
            transport: String? = nil
        ) async throws -> Components.Schemas.ScheduleResponse {
            
            let dateString: String?
            if let date = date {
                dateString = await DateFormatterCache.shared.string(from: date)
            } else {
                dateString = nil
            }
            
            let response = try await client.getStationSchedule(
                query: .init(
                    apikey: apikey,
                    station: station,
                    format: "json",
                    date: dateString,
                    transport_types: transport
                )
            )
            
            guard case let .ok(okResponse) = response else {
                throw APIError.invalidResponse
            }
            
            return try okResponse.body.json
        }
    }

enum APIError: Error {
    case invalidResponse
}

