
import Foundation
import Network

/// Класс, отвечающий за проверку наличия подключения устройства к сети интернет
class NetworkMonitor {
    /// Статический экземпляр класса
    static let shared = NetworkMonitor()
    /// Поток, на котором происоходит мониторинг подключения
    private let queue = DispatchQueue.global()
    /// Монитор, следящий за наличием подключения
    private let monitor: NWPathMonitor
    /// Подключено ли устройство к сети
    public private(set) var isConnected: Bool = true
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    /// Запуск мониторинга подключения устройства к сети интернет
    public func startMonitoring(networkAppeared: @escaping ()->(Void)) {
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
    
    /// Остановка мониторинга подключения устройства к сети интернет
    public func stopMonitoring(){
        monitor.cancel()
    }
}
