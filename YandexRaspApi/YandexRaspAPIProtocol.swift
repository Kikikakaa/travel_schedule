import Foundation

protocol YandexRaspAPIProtocol {
    func getNearestStations(lat: Double, lon: Double, distance: Int) async throws -> [Components.Schemas.Station]
    func getNearestCity(lat: Double, lon: Double, distance: Int) async throws -> Components.Schemas.NearestCityResponse
    func searchRoutes(from: String, to: String) async throws -> Components.Schemas.Segments
    func getCopyright() async throws -> Components.Schemas.Copyright
    func getCarrierInfo(code: String, system: String?) async throws -> Components.Schemas.CarrierResponse
    func getAllStations() async throws -> [Components.Schemas.Country]
    func getStationSchedule(station: String, date: Date?, transport: String?) async throws -> [Components.Schemas.Schedule]
    func getThreadStations(fromStationCode: String) async throws -> Components.Schemas.ThreadStationsResponse
    func getThread(uid: String) async throws -> Components.Schemas.ThreadStationsResponse
}

