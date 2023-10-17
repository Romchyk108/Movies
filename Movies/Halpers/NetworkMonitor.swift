//
//  NetworkMonitor.swift
//  Movies
//
//  Created by Roman Shestopal on 23.10.2023.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    weak var errorHandler: ErrorHandlerProtocol?
    
    init(errorHandler: ErrorHandlerProtocol? = nil) {
        self.errorHandler = errorHandler
    }
    
    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool {
        status == .satisfied
    }
    var isReachableOnCellular: Bool = true
    
    func startMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive
            
            if path.status != .satisfied {
                self?.errorHandler?.showErrorAlert(title: "You are offline. Please, enable your Wi-Fi or connect using cellular data.", message: nil, dismissCompletion: nil)
            }
            
            let queue = DispatchQueue(label: "Monitor")
            self?.monitor.start(queue: queue)
        }
    }
    
    func stopMonitor() {
        monitor.cancel()
    }
}
