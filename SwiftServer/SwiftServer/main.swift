//
//  main.swift
//  SwiftServer
//
//  Created by Joe Samyn on 10/12/24.
//

/**
 Request Components:
 - Start Line:
    - HTTP Method
    - Target: URI or URL, path or protocol
    - HTTP Version
 - Headers
 - Message Body
 
 */

import Foundation
import RestSwiftly

let server = Server()
server.start()

