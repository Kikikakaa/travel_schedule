import OpenAPIURLSession
import Foundation

struct APIProvider {
    static func makeDefault() -> YandexRaspAPI {
        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        let apikey = API.key
        return YandexRaspAPI(client: client, apikey: apikey)
    }
}
