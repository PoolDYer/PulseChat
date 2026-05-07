//
//  NetworkMonitor.swift
//  PulseChat
//
//  Created by Paul on 5/05/26.
//

import Network
import Foundation
import Combine

final class NetworkMonitor: ObservableObject {

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool = true

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
