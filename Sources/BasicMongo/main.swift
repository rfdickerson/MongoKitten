import Foundation
import MongoKitten

let settings = ClientSettings(host: MongoHost(hostname: "127.0.0.1",
                              port: UInt16(27017)),
                              sslSettings: nil,
                              credentials: nil)

let server = try Server(settings)
let database = server["tutorial"]
let collection = database["flight"]


if server.isConnected {
    print("Successfully connected to the server")
}

try? database.drop()

let doc: Document = [
        "_id": "0",
        "customerId": "128374",
        "flightId": "AA231",
        "dateOfBooking": Date(),
    ]

let con = try collection.insert(doc)