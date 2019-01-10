import Foundation
import CoreLocation

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    private let manager: CLLocationManager
    var didUpdate: (([CLLocation]) -> Void)?
    
    init(manager: CLLocationManager = .init()) {
        self.manager = manager
        
        super.init()
        
        self.manager.delegate = self
    }
    
    func start() {
        manager.startUpdatingLocation()
    }
    
    func stop() {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdate?(locations)
    }
}

typealias LocationCompletion = (CLLocation) -> Void
func makeFetchCurrentLocationImplementation() -> (@escaping LocationCompletion) -> Void {
    let delegate = LocationManagerDelegate()
    
    return { completion in
        delegate.didUpdate = { [weak delegate] locations in
            completion(locations.last!)
            delegate?.stop()
        }
        delegate.start()
    }
}

struct LocationManager {
    var makeFetchCurrentLocation = makeFetchCurrentLocationImplementation
}

struct Environment {
    var locationManager = LocationManager()
}

var GlobalEnvironment = Environment()

class ViewModel {
    var location: CLLocation?
    
    func updateLocation() {
        let fetchCurrentLocation = GlobalEnvironment.locationManager.makeFetchCurrentLocation()
        fetchCurrentLocation { [weak self] location in
            guard let strongSelf = self else { return }
            
            strongSelf.location = location
            
            // TODO: ...
        }
    }
}

var fakeLocation = CLLocation(latitude: 20, longitude: 20)
GlobalEnvironment.locationManager.makeFetchCurrentLocation = {
    return { callback in
        callback(fakeLocation)
    }
}

var vm: ViewModel? = ViewModel()
vm?.updateLocation()
vm?.location
vm = nil
