//
//  SSDPClient.swift
//  SSDPClient
//
//  Created by Nathan Wong on 13/01/2017.
//  Copyright © 2017 Nathan Wong. All rights reserved.
//

import Socket

public class SSDPClient {

    private let address: Socket.Address?
    private let datagram: String
    private let socket: Socket

    private let ssdpIPAddress = "239.255.255.250"
    private let ssdpPort: Int32 = 1900

    var results = [Device]()

    public init(serviceType: String = "ssdp:all") {
        address = Socket.createAddress(for: ssdpIPAddress, on: ssdpPort)
        datagram = "M-SEARCH * HTTP/1.1\nHost: 239.255.255.250:1900\nMan: \"ssdp:discover\"\nST: \(serviceType)\n"
        socket = try! Socket.create(family: .inet, type: .datagram, proto: .udp)
    }

    public func search(timeout: TimeInterval = 2.0) {
        guard let address = address,
            let data = datagram.data(using: .utf8) else {
                return
        }

        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.sync {
            do {

                let start = Date()
                try self.socket.write(from: data, to: address)

                repeat {
                    var result = Data()
                    let (_, srcAddress) = try self.socket.readDatagram(into: &result)

                    guard let device = Device.parse(data: result, address: srcAddress) else {
                        continue
                    }
                    print(device)
                    self.results.append(device)
                    self.notify()

                } while Date().timeIntervalSince(start) <= timeout


            } catch let error {
                print(error.localizedDescription)
            }
        }

    }

    private func notify() {
        print("\(results.count)")
    }
}

// -9992 address already in use (Sonos app open?)
// -9992 invalid argument write is before listen (?)
