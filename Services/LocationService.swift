import CoreLocation
import Foundation

protocol LocationServiceProtocol {
    func requestCurrentLocation() async throws -> CLLocationCoordinate2D
    func currentCountryCode() async throws -> String?
}


final class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    private var permissionContinuation: CheckedContinuation<Bool, Never>?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            let granted = await withCheckedContinuation { continuation in
                permissionContinuation = continuation
            }
            guard granted else {
                throw NSError(domain: "LocationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Разрешение на геолокацию не выдано"])
            }
        case .denied, .restricted:
            throw NSError(domain: "LocationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Разрешение на геолокацию не выдано"])
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
        }

        locationManager.requestLocation()

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.first?.coordinate {
            locationContinuation?.resume(returning: coordinate)
        } else {
            locationContinuation?.resume(throwing: NSError(domain: "LocationService", code: 0))
        }
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            permissionContinuation?.resume(returning: true)
        } else if status != .notDetermined {
            permissionContinuation?.resume(returning: false)
        }
        permissionContinuation = nil
    }
}

extension LocationService {
    func currentCountryCode() async throws -> String? {
        let coordinate = try await requestCurrentLocation()
        let location = CLLocation(latitude: coordinate.latitude,
                                  longitude: coordinate.longitude)

        return try await withCheckedThrowingContinuation { continuation in
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let countryCode = placemarks?.first?.isoCountryCode
                continuation.resume(returning: countryCode)
            }
        }
    }
}
