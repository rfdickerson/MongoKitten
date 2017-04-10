import Foundation
import Dispatch
import MongoKitten

let numberOfDocuments = 10000

//let host = "localhost"
//let port = 27017


let host = "bluemix-sandbox-dal-9-portal.7.dblayer.com"
let port = 25438

let credentials = MongoCredentials(username: "admin",
                                   password: "GMFSMMSPDGWSTEOH",
                                   database: "admin",
                                   authenticationMechanism: .MONGODB_CR
    )

let sslSettings = SSLSettings(enabled: true, invalidHostNameAllowed: true, invalidCertificateAllowed: true)

let settings = ClientSettings(host: MongoHost(hostname: host,
                              port: UInt16(port)),
                              sslSettings: sslSettings,
                              credentials: credentials)

//let settings = ClientSettings(host: MongoHost(hostname: host,
//                                              port: UInt16(port)),
//                              sslSettings: nil,
//                              credentials: nil)

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
