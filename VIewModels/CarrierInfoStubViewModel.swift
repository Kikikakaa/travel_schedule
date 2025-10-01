import Foundation

class CarrierInfoStubViewModel: ObservableObject {
    struct CarrierStub {
        let email: String?
        let phone: String?
        let logoName: String?
    }
    
    @Published var stub: CarrierStub
    private let carrierName: String
    
    init(carrierName: String, carrierCode: String?, carrierLogo: String?) {
        self.carrierName = carrierName
        self.stub = CarrierInfoStubViewModel.createCarrierStub(name: carrierName, fallbackLogo: carrierLogo)
    }
    
    var formattedTitle: String {
        let lower = carrierName.lowercased()
        if lower == "ржд" || lower.contains("ржд") {
            return "ОАО «РЖД»"
        }
        return carrierName
    }
    
    private static func createCarrierStub(name: String, fallbackLogo: String?) -> CarrierStub {
        switch name.lowercased() {
        case "ржд", "оао «ржд»", "оао ржд":
            return .init(email: "i.lozgkina@yandex.ru",
                         phone: "+7 (904) 329-27-71",
                         logoName: fallbackLogo ?? "LogoStub1")
        case "фгк":
            return .init(email: "info@fgk.ru",
                         phone: "+7 (495) 123-45-67",
                         logoName: fallbackLogo ?? "LogoStub2")
        case "урал логистика", "урал-логистика":
            return .init(email: "office@ural-logistics.ru",
                         phone: "+7 (343) 765-43-21",
                         logoName: fallbackLogo ?? "LogoStub3")
        default:
            return .init(email: nil, phone: nil, logoName: fallbackLogo)
        }
    }
    
    func digits(from phone: String) -> String {
        phone.filter { "0123456789+".contains($0) }
    }
}
