//
// This source file is part of the MongoKitten open source project
//
// Copyright (c) 2016 - 2017 OpenKitten and the MongoKitten project authors
// Licensed under MIT
//
// See https://github.com/OpenKitten/MongoKitten/blob/mongokitten31/LICENSE.md for license information
// See https://github.com/OpenKitten/MongoKitten/blob/mongokitten31/CONTRIBUTORS.md for the list of MongoKitten project authors
//

import Foundation

import Socket
import SSLService

public final class MongoSocket: MongoTCP {

  private let client: Socket?
  private let bufferSize = 4096
  private var myBuffer: Data? 

  public init(address hostname: String, port: UInt16, options: [String: Any]) throws {

    client = try Socket.create()
    client?.readBufferSize = bufferSize
    try client?.connect(to: hostname, port: Int32(port))

    myBuffer = Data(capacity: bufferSize)

  }

  public func send(data binary: [UInt8]) throws {

    let data = Data(bytes: binary)
    try client?.write(from: data)

  }

  public func receive(into buffer: inout [UInt8]) throws {

    guard let client = client else { throw MongoSocketError.clientNotInitialized }

    buffer.removeAll()

    let length = try client.read(into: &myBuffer!)
    buffer.append( contentsOf: Array(myBuffer!))

    print(length)
    
  }

  public var isConnected: Bool {
    return client?.isConnected ?? false
  }

  public func close() throws {

    guard let client = client else { throw MongoSocketError.clientNotInitialized }

    client.close()

  }

}

// import Sockets
// import TLS

// public final class MongoSocket: MongoTCP {
//     private let plainClient: TCPInternetSocket?
//     private let sslClient: TLS.Socket?
//     private var sslEnabled = false
//
//     public init(address hostname: String, port: UInt16, options: [String: Any]) throws {
//         self.sslEnabled = options["sslEnabled"] as? Bool ?? false
//
//         if sslEnabled {
//             plainClient = nil
//             let address = hostname.lowercased() == "localhost" ? InternetAddress.localhost(port: port) : InternetAddress.init(hostname: hostname, port: port)
//
//             let internetSocket = try TCPInternetSocket(address, scheme: "mongodb")
//
//             sslClient = try TLS.InternetSocket(internetSocket, TLS.Context(.client))
//             try sslClient?.socket.connect()
//         } else {
//             sslClient = nil
//             let address = hostname.lowercased() == "localhost" ? InternetAddress.localhost(port: port) : InternetAddress(hostname: hostname, port: port)
//             plainClient = try TCPInternetSocket(address, scheme: "mongodb")
//             try plainClient?.connect()
//         }
//     }
//
//     /// Sends the data to the other side of the connection
//     public func send(data binary: [UInt8]) throws {
//         if sslEnabled {
//             try sslClient?.socket.write(binary, flushing: true)
//         } else {
//             try plainClient?.write(binary, flushing: true)
//         }
//     }
//
//     /// Receives any available data from the socket
//     public func receive(into buffer: inout [UInt8]) throws {
//         buffer.removeAll()
//         if sslEnabled {
//             guard let sslClient = sslClient else { throw MongoSocketError.clientNotInitialized }
//             buffer.append(contentsOf: try sslClient.socket.read(max: Int(UInt16.max)))
//         } else {
//             guard let plainClient = plainClient else { throw MongoSocketError.clientNotInitialized }
//             buffer.append(contentsOf: try plainClient.read(max: Int(UInt16.max)))
//         }
//     }
//
//     /// `true` when connected, `false` otherwise
//     public var isConnected: Bool {
//         if sslEnabled {
//             return !(sslClient?.socket.isClosed ?? false)
//         } else {
//             return !(plainClient?.isClosed ?? false)
//         }
//     }
//
//     /// Closes the connection
//     public func close() throws {
//         if sslEnabled {
//             guard let sslClient = sslClient else { throw MongoSocketError.clientNotInitialized }
//             try sslClient.close()
//         } else {
//             guard let plainClient = plainClient else { throw MongoSocketError.clientNotInitialized }
//             try plainClient.close()
//         }
//     }
// }
