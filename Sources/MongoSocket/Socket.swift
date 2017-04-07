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
  private var sslEnabled = false

  public init(address hostname: String, port: UInt16, options: [String: Any]) throws {

    self.sslEnabled = options["sslEnabled"] as? Bool ?? false
    client = try Socket.create()

    guard let client = client else { throw MongoSocketError.clientNotInitialized }

    // try client.setBlocking(mode: false)
    client.readBufferSize = bufferSize
    try client.connect(to: hostname, port: Int32(port))

    myBuffer = Data(capacity: bufferSize)

  }

  public func send(data binary: [UInt8]) throws {

    let data = Data(bytes: binary)
    try client?.write(from: data)

  }

  public func receive(into buffer: Buffer) throws {

   

    guard let client = client else { throw MongoSocketError.clientNotInitialized }

    // buffer.removeAll()

    // receivedBytes = try client.read(into: &myBuffer)
    // buffer.append( contentsOf: Array(myBuffer))

    try buffer.pointer.withMemoryRebound(to: CChar.self, capacity: Int(UInt16.max)) {

        var receivedBytes: Int

        receivedBytes = try! client.read(into: $0, bufSize: Int(UInt16.max))

        guard receivedBytes != -1 else {
        _ = try self.close()
        return
    }

    buffer.usedCapacity = receivedBytes
    }
    

    

  }

  public var isConnected: Bool {
    return client?.isConnected ?? false
  }

  public func close() throws {

    guard let client = client else { throw MongoSocketError.clientNotInitialized }

    client.close()

  }
}

