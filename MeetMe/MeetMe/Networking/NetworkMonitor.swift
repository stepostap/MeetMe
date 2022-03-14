
import Foundation
import Network

class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    
    public private(set) var isConnected: Bool = true
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring(networkAppeared: @escaping ()->(Void) ){
        
        monitor.pathUpdateHandler = { [weak self] path in
            
            guard let this = self else {
                return
            }
            
            if !this.isConnected && path.status == .satisfied {
                this.isConnected = true
                DispatchQueue.main.async {
                    networkAppeared()
                }
            }
            
            this.isConnected = path.status == .satisfied
        }
        
        monitor.start(queue: queue)
    }
    
    public func stopMonitoring(){
        monitor.cancel()
    }
}
