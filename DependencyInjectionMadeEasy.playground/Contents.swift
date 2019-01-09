import Foundation
import CoreLocation

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    private let manager: CLLocationManager
    private let didUpdate: ([CLLocation]) -> Void
    
    init(manager: CLLocationManager = .init(), didUpdate: @escaping ([CLLocation]) -> Void) {
        self.manager = manager
        self.didUpdate = didUpdate
        
        super.init()
        
        self.manager.delegate = self
    }
    
    func start() {
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdate(locations)
        manager.stopUpdatingLocation()
    }
}

@discardableResult
func fetchCurrentLocation(with completion: @escaping (CLLocation) -> Void) -> Any {
    let delegate = LocationManagerDelegate { locations in
        completion(locations.first!)
    }
    delegate.start()
    
    return delegate
}

struct LocationManager {
    var fetchCurrentLocation = fetchCurrentLocation(with:)
}

struct Environment {
    var locationManager = LocationManager()
}

var GlobalEnvironment = Environment()

class ViewModel {
    enum Constant {
        static let locationReferenceKey = "this is a key"
    }
    
    private var strongReferences: [String: Any] = [:]
    var location: CLLocation?
    
    func updateLocation() {
        let reference = GlobalEnvironment.locationManager.fetchCurrentLocation { [weak self] location in
            guard let strongSelf = self else { return }
            strongSelf.location = location
            
            // TODO: ...
            
            strongSelf.strongReferences.removeValue(forKey: Constant.locationReferenceKey)
        }
        
        strongReferences[Constant.locationReferenceKey] = reference
    }
}

var fakeLocation = CLLocation(latitude: 20, longitude: 20)
GlobalEnvironment.locationManager.fetchCurrentLocation = { callback in
    callback(fakeLocation)
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { callback(fakeLocation) })
    return ""
}

var vm: ViewModel? = ViewModel()
vm?.updateLocation()
vm?.location
vm = nil
