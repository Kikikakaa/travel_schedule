import Foundation

extension Components.Schemas.Settlement {
    var yandexID: String? { codes?.yandex_code }
}

import Foundation

extension Components.Schemas.Carrier {
    var preferredCodeAndSystem: (code: String, system: String)? {
        if let iata = codes?.iata {
            return (iata, "iata")
        } else if let icao = codes?.icao {
            return (icao, "icao")
        } else if let sirena = codes?.sirena {
            return (sirena, "sirena")
        }
        return nil
    }
}

