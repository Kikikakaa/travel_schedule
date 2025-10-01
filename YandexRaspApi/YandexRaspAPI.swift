import Foundation
import OpenAPIURLSession

actor YandexRaspAPI: YandexRaspAPIProtocol {
    
    typealias CopyrightInfo = Components.Schemas.Copyright
    typealias Carrier = Components.Schemas.Carrier
    typealias CarrierResponse = Components.Schemas.CarrierResponse
    typealias AllStationsResponse = Components.Schemas.AllStationsResponse
    typealias Country = Components.Schemas.Country
    typealias Thread = Components.Schemas.Thread
    typealias StationSchedule = Components.Schemas.ScheduleResponse
    typealias Schedule = Components.Schemas.Schedule
    
    private let client: Client
    private let apikey: String
    
    private let nearestStations: NearestStationsService
    private let nearestCity: NearestCityService
    private let routeSearch: RouteSearchService
    private let copyright: CopyrightService
    private let carrierInfo: CarrierInfoService
    private let allStations: AllStationsService
    private let stationSchedule: StationScheduleService
    private let threadStations: ThreadStationsService
    typealias ThreadStationsResponse = Components.Schemas.ThreadStationsResponse
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
        
        self.nearestStations = NearestStationsService(client: client, apikey: apikey)
        self.nearestCity = NearestCityService(client: client, apikey: apikey)
        self.routeSearch = RouteSearchService(client: client, apikey: apikey)
        self.copyright = CopyrightService(client: client, apikey: apikey)
        self.carrierInfo = CarrierInfoService(client: client, apikey: apikey)
        self.allStations = AllStationsService(client: client, apikey: apikey)
        let stationScheduleService = StationScheduleService(client: client, apikey: apikey)
        self.stationSchedule = stationScheduleService
        self.threadStations = ThreadStationsService(client: client, apikey: apikey, stationScheduleService: stationScheduleService)
    }
    
    // MARK: - API methods
    func getNearestStations(lat: Double, lon: Double, distance: Int = 50) async throws -> [Components.Schemas.Station] {
        let response: NearestStations = try await nearestStations.getNearestStations(
            lat: lat,
            lng: lon,
            distance: distance
        )
        return response.stations ?? []
    }
    
    func getNearestCity(lat: Double, lon: Double, distance: Int = 50) async throws -> Components.Schemas.NearestCityResponse {
        try await nearestCity.getNearestCity(
            lat: lat,
            lng: lon,
            distance: distance
        )
    }
    
    func searchRoutes(from: String, to: String) async throws -> Components.Schemas.Segments {
        try await routeSearch.getRoutes(from: from, to: to)
    }
    
    
    func getCopyright() async throws -> CopyrightInfo {
        try await copyright.getCopyright()
    }
    
    func getCarrierInfo(code: String, system: String? = "iata") async throws -> CarrierResponse {
        try await carrierInfo.getCarrierInfo(code: code, system: system)
    }
    
    func getAllStations() async throws -> [Country] {
        let response = try await allStations.getAllStations()
        return response.countries ?? []
    }
    
    func getStationSchedule(station: String, date: Date?, transport: String? = nil) async throws -> [Schedule] {
        let response = try await stationSchedule.getStationSchedule(
            station: station,
            date: date,
            transport: transport
        )
        return response.schedule ?? []
    }
    
    func getThreadStations(fromStationCode: String) async throws -> ThreadStationsResponse {
        try await threadStations.getRouteStations(fromStationCode: fromStationCode)
    }
    
    func getThread(uid: String) async throws -> ThreadStationsResponse {
        try await threadStations.getRouteStationsRaw(uid: uid)
    }
    
}
