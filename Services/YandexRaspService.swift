import Foundation
import UIKit
import OpenAPIRuntime
import OpenAPIURLSession

protocol YandexRaspServiceProtocol {
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> Components.Schemas.Stations
    func getScheduleBetweenStations(from: String, to: String, date: String?, limit: Int?) async throws -> Components.Schemas.Segments
    func getStationSchedule(station: String, date: String?, event: String) async throws -> Components.Schemas.ScheduleResponse
    func getRouteStations(uid: String, from: String?, to: String?) async throws -> Components.Schemas.ThreadStationsResponse
    func getNearestCity(lat: Double, lng: Double, distance: Int) async throws -> Components.Schemas.NearestCityResponse
    func getCarrierInfo(code: String, system: String?) async throws -> Components.Schemas.CarrierResponse
    func getCopyright() async throws -> Components.Schemas.CopyrightResponse
    func getAllStations() async throws -> Components.Schemas.AllStationsResponse
}

// MARK: - Main Service Implementation

final class YandexRaspService: YandexRaspServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    convenience init(apikey: String) {
        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        self.init(client: client, apikey: apikey)
    }
    
    // MARK: - Nearest Stations
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> Components.Schemas.Stations {
        let response = try await client.getNearestStations(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance
        ))
        return try response.ok.body.json
    }
    
    // MARK: - Schedule Between Stations
    func getScheduleBetweenStations(
        from: String,
        to: String,
        date: String? = nil,
        limit: Int? = nil
    ) async throws -> Components.Schemas.Segments {
        let response = try await client.getScheduleBetweenStations(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            format: .json,
            lang: "ru_RU",
            date: date,
            limit: limit
        ))
        return try response.ok.body.json
    }

    
    // MARK: - Station Schedule
    func getStationSchedule(station: String, date: String? = nil, event: String = "departure") async throws -> Components.Schemas.ScheduleResponse {
        let response = try await client.getStationSchedule(query: .init(
            apikey: apikey,
            station: station,
            lang: "ru_RU",
            format: "json",
            date: date,
            transport_types: nil,
            event: event, // Добавляем обязательный параметр
            direction: nil,
            system: nil,
            result_timezone: nil
        ))
        return try response.ok.body.json
    }
    
    // MARK: - Route Stations
    func getRouteStations(uid: String, from: String? = nil, to: String? = nil) async throws -> Components.Schemas.ThreadStationsResponse {
        let response = try await client.getRouteStations(query: .init(
            apikey: apikey,
            uid: uid,
            from: from,
            to: to,
            format: "json",
            lang: "ru_RU"
        ))
        return try response.ok.body.json
    }
    
    // MARK: - Nearest City
    func getNearestCity(lat: Double, lng: Double, distance: Int = 50) async throws -> Components.Schemas.NearestCityResponse {
        let response = try await client.getNearestCity(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance,
            lang: "ru_RU", // Добавляем язык
            format: "json"
        ))
        return try response.ok.body.json
    }
    
    // MARK: - Carrier Info
    func getCarrierInfo(code: String, system: String? = nil) async throws -> Components.Schemas.CarrierResponse {
        let response = try await client.getCarrierInfo(query: .init(
            apikey: apikey,
            code: code,
            system: system
        ))
        return try response.ok.body.json
    }
    
    // MARK: - Copyright
    func getCopyright() async throws -> Components.Schemas.CopyrightResponse {
        let response = try await client.getCopyright(query: .init(
            apikey: apikey
        ))
        return try response.ok.body.json
    }
    
    // MARK: - All Stations
    func getAllStations() async throws -> Components.Schemas.AllStationsResponse {
       let response = try await client.getAllStations(query: .init(apikey: apikey))

       let responseBody = try response.ok.body.html

       let limit = 50 * 1024 * 1024 // 50Mb
       var fullData = try await Data(collecting: responseBody, upTo: limit)

       let allStations = try JSONDecoder().decode(Components.Schemas.AllStationsResponse.self, from: fullData)

       return allStations
    }
}


func testGetNearestStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = YandexRaspService(
                client: client,
                apikey: "c55262b4-2eb3-4048-bc82-05295a604f6c" // !!! ЗАМЕНИТЕ НА СВОЙ РЕАЛЬНЫЙ КЛЮЧ !!!
            )
            
            print("🚉 Fetching nearest stations...")
            let stations = try await service.getNearestStations(
                lat: 59.864177, // Координаты СПб
                lng: 30.319163,
                distance: 50
            )
            
            print("✅ Successfully fetched \(stations.stations?.count ?? 0) nearest stations")
            if let firstStation = stations.stations?.first {
                print("   First station: \(firstStation.title ?? "Unknown")")
            }
        } catch {
            print("❌ Error fetching nearest stations: \(error)")
        }
    }
}

///2. Тест поиска расписания между станциями
func testGetScheduleBetweenStations() async throws {
    let service = YandexRaspService(
        apikey: "c55262b4-2eb3-4048-bc82-05295a604f6c"
    )

    print("🚄 Fetching schedule between stations...")

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateFormatter.string(from: Date())
    
    let segments = try await service.getScheduleBetweenStations(
        from: "s2000001",
        to: "s9623131",
        date: today,
        limit: 1
    )

    print("✅ Successfully fetched \(segments.segments?.count ?? 0) segments")

    if let firstSegment = segments.segments?.first {
        print("   First route: \(firstSegment.thread?.title ?? "Unknown")")
        if let departure = firstSegment.departure {
            print("   Departure: \(departure)")
        }
        if let arrival = firstSegment.arrival {
            print("   Arrival: \(arrival)")
        }
    }
}

/// 3. Тест получения расписания по станции
func testGetStationSchedule() async throws {
    let service = YandexRaspService(
        apikey: "c55262b4-2eb3-4048-bc82-05295a604f6c"
    )
    
    print("📅 Fetching station schedule...")
    
    // Получаем текущую дату в правильном формате
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateFormatter.string(from: Date())
    
    let scheduleResponse = try await service.getStationSchedule(
        station: "s9600213", // Санкт-Петербург (Главный)
        date: today,
        event: "departure"
    )
    
    print("✅ Successfully fetched schedule for station: \(scheduleResponse.station?.title ?? "Unknown")")
    print("   Scheduled items count: \(scheduleResponse.schedule?.count ?? 0)")
    if let firstSchedule = scheduleResponse.schedule?.first {
        print("   Thread: \(firstSchedule.thread?.title ?? "Unknown")")
    }
}

/// 4. Тест получения станций маршрута
func testGetRouteStations() async throws {
    let service = YandexRaspService(
        apikey: "c55262b4-2eb3-4048-bc82-05295a604f6c"
    )
    
    print("🛤️ Fetching route stations...")
    
    // Сначала получаем расписание, чтобы взять uid
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateFormatter.string(from: Date())
    
    let segments = try await service.getScheduleBetweenStations(
        from: "s2000001",   // Москва Курский
        to: "s9623131",     //ТУла 
        date: today,
        limit: 1
    )
    
    guard let firstSegment = segments.segments?.first,
          let uid = firstSegment.thread?.uid else {
        print("⚠️ No segments found or UID missing")
        return
    }
    
    print("✅ Got UID: \(uid)")
    
    // Теперь получаем станции маршрута по UID
    let threadResponse = try await service.getRouteStations(
        uid: uid,
        from: nil,
        to: nil
    )
    
    print("✅ Successfully fetched route: \(threadResponse.title ?? "Unknown")")
    print("   From: \(threadResponse.from?.title ?? "Unknown")")
    print("   To: \(threadResponse.to?.title ?? "Unknown")")
    print("   Stops count: \(threadResponse.stops?.count ?? 0)")
    
    if let stops = threadResponse.stops?.prefix(5) {
        print("   First 5 stops:")
        for stop in stops {
            print("     - \(stop.station?.title ?? "Unknown")")
        }
    }
}

/// 5. Тест поиска ближайшего города
func testGetNearestCity() async throws {
    let service = YandexRaspService(
        apikey: "c55262b4-2eb3-4048-bc82-05295a604f6c"
    )
    
    print("🏙️ Fetching nearest city...")
    
    // Попробуем координаты Москвы
    let cityResponse = try await service.getNearestCity(
        lat: 55.7558,
        lng: 37.6173,
        distance: 50
    )
    
    print("✅ Successfully found nearest city: \(cityResponse.title ?? "Unknown")")
    print("   Distance: \(cityResponse.distance ?? 0) km")
    print("   Code: \(cityResponse.code ?? "Unknown")")
}

/// 6. Тест получения информации о перевозчике
func testGetCarrierInfo() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = YandexRaspService(
                client: client,
                apikey: "c55262b4-2eb3-4048-bc82-05295a604f6c" // !!! ЗАМЕНИТЕ НА СВОЙ РЕАЛЬНЫЙ КЛЮЧ !!!
            )
            
            print("✈️ Fetching carrier info...")
            let carrierResponse = try await service.getCarrierInfo(
                code: "SU", // Пример кода перевозчика (Аэрофлот)
                system: "iata"
            )
            
            print("✅ Successfully fetched carrier info")
            if let firstCarrier = carrierResponse.carriers?.first {
                print("   Carrier: \(firstCarrier.title ?? "Unknown")")
                print("   Code: \(firstCarrier.code ?? 0)")
                print("   URL: \(firstCarrier.url ?? "Unknown")")
                print("   Phone: \(firstCarrier.phone ?? "Unknown")")
            }
        } catch {
            print("❌ Error fetching carrier info: \(error)")
        }
    }
}

/// 7. Тест получения информации об авторских правах
func testGetCopyright() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = YandexRaspService(
                client: client,
                apikey: "c55262b4-2eb3-4048-bc82-05295a604f6c" // !!! ЗАМЕНИТЕ НА СВОЙ РЕАЛЬНЫЙ КЛЮЧ !!!
            )
            
            print("📄 Fetching copyright info...")
            let copyrightResponse = try await service.getCopyright()
            
            print("✅ Successfully fetched copyright info")
            print("   Organization: \(copyrightResponse.organization ?? "Unknown")")
            print("   Copyright text: \(copyrightResponse.copyright?.text ?? "Unknown")")
            print("   Copyright URL: \(copyrightResponse.copyright?.url ?? "Unknown")")
            print("   Resources count: \(copyrightResponse.resources?.count ?? 0)")
        } catch {
            print("❌ Error fetching copyright: \(error)")
        }
    }
}

/// 8. Тест получения списка всех станций
func testGetAllStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = YandexRaspService(
                client: client,
                apikey: "c55262b4-2eb3-4048-bc82-05295a604f6c" // !!! ЗАМЕНИТЕ НА СВОЙ РЕАЛЬНЫЙ КЛЮЧ !!!
            )
            
            print("🌍 Fetching all stations... (This may take a while)")
            let allStationsResponse = try await service.getAllStations()
            
            print("✅ Successfully fetched all stations")
            print("   Countries count: \(allStationsResponse.countries?.count ?? 0)")
            
            if let firstCountry = allStationsResponse.countries?.first {
                print("   First country: \(firstCountry.title ?? "Unknown")")
                print("   Regions count: \(firstCountry.regions?.count ?? 0)")
                
                if let firstRegion = firstCountry.regions?.first {
                    print("   First region: \(firstRegion.title ?? "Unknown")")
                    print("   Settlements count: \(firstRegion.settlements?.count ?? 0)")
                }
            }
        } catch {
            print("❌ Error fetching all stations: \(error)")
        }
    }
}

func testGetActualStationCodes() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = YandexRaspService(
                client: client,
                apikey: "c55262b4-2eb3-4048-bc82-05295a604f6c"
            )
            
            print("🔍 Getting actual station codes...")
            
            // Получаем ближайшие станции
            let stations = try await service.getNearestStations(
                lat: 55.7558, // Москва
                lng: 37.6173,
                distance: 10
            )
            
            print("✅ Found \(stations.stations?.count ?? 0) stations")
            
            // Железнодорожные станции
            let railStations = stations.stations?.filter { station in
                station.transport_type?.lowercased().contains("train") == true ||
                station.station_type?.lowercased().contains("station") == true
            }
            
            print("\n🚂 Railway stations found:")
            railStations?.prefix(5).forEach { station in
                print("   \(station.title ?? "Unknown") - code: '\(station.code ?? "no_code")'")
            }
            
        } catch {
            print("❌ Error getting station codes: \(error)")
        }
    }
}

// MARK: - Функция для запуска всех тестов

/// Функция для запуска всех тестов последовательно
func runAllTests() async {
    print("🚀 Starting API tests...\n")
    
    do {
        try await testGetNearestStations()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        try await testGetScheduleBetweenStations()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        try await testGetStationSchedule()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        try await testGetRouteStations()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        try await testGetNearestCity()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        try await testGetCarrierInfo()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        try await testGetCopyright()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        try await testGetAllStations()
        
        print("\n✅ All tests completed successfully!")
        
    } catch {
        print("❌ Error during tests: \(error)")
        print("Error details: \(error.localizedDescription)")
    }
}

