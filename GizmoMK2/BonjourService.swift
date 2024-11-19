//
//  BonjourService.swift
//  GizmoMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation
import Combine
import Network

// Structure representing a client discovered over Bonjour
struct FoundHost: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let hostName: String
    let port: Int
}

class BonjourService: NSObject, ObservableObject {
    @Published var discoveredClients: [FoundHost] = []
    
    private var browser: NetServiceBrowser?
    private var resolvingServices: Set<NetService> = []
    
    // Function to start browsing for services
    func startBrowsing(serviceType: String, domain: String = "") {
        browser = NetServiceBrowser()
        browser?.delegate = self
        browser?.searchForServices(ofType: serviceType, inDomain: domain)
        print("Started browsing for services of type \(serviceType)...")
    }
    
    // Function to stop browsing for services
    func stopBrowsing() {
        browser?.stop()
        browser = nil
        print("Stopped browsing for services.")
    }
}

// MARK: - NetServiceBrowserDelegate
extension BonjourService: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("Found service: \(service.name)")
        service.delegate = self
        service.schedule(in: .main, forMode: .default)
        service.resolve(withTimeout: 5)
        
        // Retain the service to prevent deallocation
        resolvingServices.insert(service)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("Removed service: \(service.name)")
        DispatchQueue.main.async {
            self.discoveredClients.removeAll { $0.name == service.name }
        }
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("Service browsing stopped.")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Failed to start browsing: \(errorDict)")
    }
}

// MARK: - NetServiceDelegate
extension BonjourService: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("Resolved service: \(sender.name)")
        
        guard let hostName = sender.hostName else {
            print("No hostname found for service: \(sender.name)")
            resolvingServices.remove(sender)
            return
        }
        
        let host = FoundHost(name: sender.name, hostName: hostName, port: sender.port)
        DispatchQueue.main.async {
            self.discoveredClients.append(host)
            print("Added host: \(host)")
        }
        
        // Release the service after resolving
        resolvingServices.remove(sender)
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Failed to resolve service \(sender.name): \(errorDict)")
        resolvingServices.remove(sender)
    }
}
