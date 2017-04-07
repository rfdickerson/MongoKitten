import Foundation
import Dispatch
import MongoKitten

let numberOfDocuments = 10000
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

var documents = [Document]()
for id in 0..<numberOfDocuments {
    let doc: Document = [
        "_id": "\(id)",
        "customerId": "128374",
        "flightId": "AA231",
        "dateOfBooking": Date(),
    ]
    documents.append(doc)
}

let queue = DispatchQueue(label: "insertion", attributes: .concurrent)
let dispatchGroup = DispatchGroup()
let parallel = true

documents.forEach { doc in 

    if parallel {
        queue.async(group: dispatchGroup) {

            do {
                try collection.insert( doc )
            } catch let error as InsertErrors {
                print("error \(error)")
            } catch let error as MongoError {
                print("error \(error)")
            } catch {
                print("Anything else")
            }

        }

    } else {

        do {
            try collection.insert( doc )
        } catch let error as InsertErrors {
            print("error")
        } catch {
            print("Anything else")
        }
    }

}

if parallel {
    dispatchGroup.wait()
}

print("Finished adding \(documents.count) documents to the database")