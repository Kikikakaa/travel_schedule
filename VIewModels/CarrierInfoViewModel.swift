import SwiftUI

@MainActor
final class CarrierInfoViewModel: ObservableObject {
    @Published var carrier: Components.Schemas.Carrier?
    @Published var isLoading: Bool = false
    @Published var showConnectionError: Bool = false
    @Published var showServerError: Bool = false
    
    private let api: YandexRaspAPIProtocol
    private let carrierCode: String
    private let system: String
    private let fallbackCarrier: Components.Schemas.Carrier?
 
    init(api: YandexRaspAPIProtocol,
         carrierCode: String,
         system: String,
         fallbackCarrier: Components.Schemas.Carrier?) {
        self.api = api
        self.carrierCode = carrierCode
        self.system = system
        self.fallbackCarrier = fallbackCarrier
    }
    
    func loadCarrierInfo() async {
        isLoading = true
        
        guard !carrierCode.isEmpty,
              ["iata", "icao", "sirena"].contains(system.lowercased())
        else {
            carrier = fallbackCarrier
            isLoading = false
            return
        }
        
        do {
            let result = try await api.getCarrierInfo(code: carrierCode, system: system)
            
            if let carrier = result.carrier {
                self.carrier = carrier
            } else if let carriers = result.carriers, !carriers.isEmpty {
                self.carrier = carriers.first
            } else {
                self.carrier = fallbackCarrier
            }
            
            isLoading = false
        } catch {
            isLoading = false
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .timedOut, .cannotFindHost, .cannotConnectToHost:
                    showConnectionError = true
                default:
                    showServerError = true
                }
            } else {
                showServerError = true
            }
        }
    }
    
    // MARK: - Helpers
    func formattedTitle(_ raw: String) -> String {
        let cleaned = raw.replacingOccurrences(of: "/ФПК", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.lowercased().contains("ржд") {
            return "ОАО «РЖД»"
        }
        return cleaned
    }
    
    func extractedEmail() -> String? {
        if let email = carrier?.email, !email.isEmpty {
            return email
        }
        if let contacts = carrier?.contacts,
           let match = contacts.range(
            of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
            options: .regularExpression
           ) {
            return String(contacts[match])
        }
        return nil
    }
    
    func extractedPhone() -> String? {
        if let phone = carrier?.phone, !phone.isEmpty {
            return phone
        }
        if let contacts = carrier?.contacts,
           let match = contacts.range(
            of: "\\+?[0-9][0-9\\-\\s()]{5,}",
            options: .regularExpression
           ) {
            return String(contacts[match])
        }
        return nil
    }
    
    private func digits(from phone: String) -> String {
        phone.filter { "0123456789+".contains($0) }
    }
    
    func phoneLink(from value: String?) -> String? {
        guard let value = value else { return nil }
        return digits(from: value)
    }
}
