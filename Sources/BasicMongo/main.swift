import Foundation
import Dispatch
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

var documents = [Document]()
for id in 0..<10000 {
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
let parallel = false

documents.forEach() { doc in 

    if parallel {
        queue.async(group: dispatchGroup) {
            try! collection.insert( doc )

        }
    } else {
        try! collection.insert( doc )
    }

}

if parallel {
    dispatchGroup.wait()
}

// let doc: Document = [
//         "_id": "0",
//         "customerId": "128374",
//         "flightId": "AA231",
//         "dateOfBooking": Date(),
//     ]

// try collection.insert(doc)