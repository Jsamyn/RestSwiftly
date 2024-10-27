//
//  testServer.swift
//  SwiftServer
//
//  Created by Joe Samyn on 10/27/24.
//

import Foundation
import Network


struct Request {
    var httpMethod: String
    var target: String
    var httpVersion: String
    var headers: [String:String]
    var body: String
}

func run() {
    do {
        let networkListener = try NWListener(using: NWParameters.tcp, on: NWEndpoint.Port(rawValue: 5001)!)
        networkListener.newConnectionHandler = connectionHandler
        
        networkListener.start(queue: DispatchQueue.main)
        
    } catch {
        print(error)
    }
    
    RunLoop.main.run()
}


func connectionHandler(connection: NWConnection) {
    connection.start(queue: .main)
    handleConnection(on: connection)
}

func handleConnection(on connection: NWConnection) {
    connection.receive(minimumIncompleteLength: 1, maximumLength: 65536, completion:  { (data, _, _, error) in
        if let data = data {
            let req = parseRequest(data: data)
            print(req ?? "No request parsed.")
            
            sendResponse(connection: connection)
        }
    })
}


func sendResponse(connection: NWConnection) {
    let httpResponse =
    """
    HTTP/1.1 200 OK
    Content-Length: 13\r
    Content-Type: text/html\r
    Connection: close\r
    \r
    Hello, World!
    """
    
    let data = httpResponse.data(using: .utf8)
    connection.send(content: data, completion: .contentProcessed({ error in
        if let error = error {
            print("Failed to send response \(error)")
        } else {
            connection.cancel()
        }
    }))
}


func parseRequest(data: Data?) -> Request? {
    
    if let data = data {
        let responseString = String(data: data, encoding: .utf8)
        
        let splitRequest = responseString?.split { $0.isNewline }.map{ String($0) } ?? []
        let startLine = splitRequest[0].split { $0.isWhitespace }.map { String($0) }
        let splitBodyFromHeaders = responseString?.components(separatedBy: "\r\n\r\n") ?? []
        let body = splitBodyFromHeaders[1]
        let unparsedHeaders = splitBodyFromHeaders[0]
        let headers = parseHeaders(unparsedHeaders: unparsedHeaders)
        
        let request = Request(httpMethod: startLine[0], target: startLine[1], httpVersion: startLine[2], headers: headers, body: body)
        return request
    }
    
    return nil
}

func parseHeaders(unparsedHeaders: String) -> [String:String] {
    
    // Discard first start line
    var splitHeaders = unparsedHeaders.split { $0.isNewline }.map{ String($0) }
    splitHeaders.removeFirst()
    
    var headers: [String:String] = [:]
    for header in splitHeaders {
        var cleanedHeader = header.replacingOccurrences(of: "\r", with: "")
        cleanedHeader = header.replacingOccurrences(of: "\n", with: "")
        let h = cleanedHeader.components(separatedBy: ": ")
        headers[h[0]] = h[1]
    }
    
    return headers
}
