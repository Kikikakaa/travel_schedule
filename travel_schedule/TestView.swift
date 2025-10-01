//import SwiftUI
//
//struct TestView: View {
//    @StateObject var vm: CitySearchViewModel
//    
//    init(service: YandexRaspServiceProtocol, locationService: LocationServiceProtocol) {
//        _vm = StateObject(wrappedValue: CitySearchViewModel(
//            stationsVM: AllStationsViewModel(service: service),
//            locationService: locationService
//        ))
//    }
//    
//    var body: some View {
//        VStack {
//            Text("Cities: \(vm.cities.count)")
//            Text("Is Loading: \(vm.isLoading ? "Yes" : "No")")
//            if let error = vm.errorMessage {
//                Text("Error: \(error)")
//            }
//        }
//        .onAppear {
//            print("🎬 TestView: Appeared, calling loadCities")
//            vm.loadCities()
//        }
//        .onChange(of: vm.isLoading) { _, newValue in
//            print("🖼️ TestView: isLoading changed to \(newValue)")
//        }
//        .onChange(of: vm.cities) { _, newValue in
//            print("🖼️ TestView: cities.count changed to \(newValue.count)")
//        }
//        .onChange(of: vm.errorMessage) { _, newValue in
//            print("🖼️ TestView: errorMessage changed to \(newValue ?? "nil")")
//        }
//    }
//}
