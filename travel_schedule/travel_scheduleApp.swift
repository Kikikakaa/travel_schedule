//
//  travel_scheduleApp.swift
//  travel_schedule
//
//  Created by user on 05.09.2025.
//

import SwiftUI

@main
struct travel_scheduleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//import SwiftUI
//import OpenAPIURLSession
//
//@main
//struct YourAppNameApp: App {
//    let service = YandexRaspService(
//        client: Client(
//            serverURL: try! Servers.Server1.url(),
//            transport: URLSessionTransport()
//        ),
//        apikey: "c55262b4-2eb3-4048-bc82-05295a604f6c" // Your API key
//    )
//    let locationService: LocationServiceProtocol = LocationService()
//    
//    var body: some Scene {
//        WindowGroup {
//            NavigationView {
//                TestView(service: service, locationService: locationService)
//            }
//        }
//    }
//}
