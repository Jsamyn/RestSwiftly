//
//  Server.swift
//  RestSwiftly
//
//  Created by Joe Samyn on 10/27/24.
//

import Foundation
import Network

/// The base server class that includes initialization code, configuration functions, middleware registration functions, etc.
public final class Server {
    
    /// Port to bind the server too
    /// - Note: Default Port is 8080
    public var port: Int
    
    public init(port: Int = 8080) {
        self.port = port
        print("Server initialized...")
    }
    
    /// Start the server and run it on the specified port.
    public func start() {
        do {
            let networkListener = try NWListener(using: NWParameters.tcp, on: NWEndpoint.Port(rawValue: UInt16(port))!)
            networkListener.newConnectionHandler = connectionHandler
            
            networkListener.start(queue: DispatchQueue.main)
            
            print("Server started and running on port \(port)")
        } catch {
            print("Failed to start server.")
            print(error)
        }
        
        // Keep main thread running
        dispatchMain()
    }
    
    // MARK: Private Functions
    
    /// Handle incoming TCP connections
    /// - Parameters:
    ///     - connection: Information about the current bidirectional connection that has been established with the client
    private func connectionHandler(_ connection: NWConnection) {
        
        // Parse and route connections to proper handlers/controllers
        
        print("Connection received...")
        connection.start(queue: .main)
    }
    
}
