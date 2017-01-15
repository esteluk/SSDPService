//
//  SSDPService.swift
//  SSDPService
//
//  Created by Nathan Wong on 13/01/2017.
//  Copyright © 2017 Nathan Wong. All rights reserved.
//

import Socket

public class SSDPService {

    private let address: Socket.Address?
    private let datagram: String

    private static let ssdpIPAddress = "239.255.255.250"
    private static let ssdpPort: Int = 1900

    public weak var delegate: SSDPServiceDelegate?

    public init(serviceType: String = "ssdp:all") {
        address = Socket.createAddress(for: SSDPService.ssdpIPAddress, on: Int32(SSDPService.ssdpPort))
        datagram = "M-SEARCH * HTTP/1.1\nHost: 239.255.255.250:1900\nMan: \"ssdp:discover\"\nST: \(serviceType)\n"
    }

    /// Creates a network query for SSDP devices on the local network. Calls the delegate with a the devices that reply
    /// before the timeout has expired.
    ///
    /// - Parameter timeout: the amount of time in seconds to wait for network responses to the SSDP query
    public func search(timeout: TimeInterval = 2.0) {
        guard let address = address,
            let data = datagram.data(using: .utf8) else {
                return
        }

        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async {
            do {

                var results = [Device]()
                let socket = try Socket.create(family: .inet, type: .datagram, proto: .udp)

                let start = Date()
                var dummy = Data()

                try socket.setBlocking(mode: false)
                try socket.listen(on: SSDPService.ssdpPort)
                try socket.write(from: data, to: address)
                let (_, _) = try socket.listen(forMessage: &dummy, on: SSDPService.ssdpPort) // ???

                repeat {
                    let sockets = try Socket.wait(for: [socket], timeout: UInt(timeout*1000))
                    if let socket = sockets?.first {
                        var data = Data()
                        let (_, srcAddress) = try socket.readDatagram(into: &data)
                        guard let device = Device.parse(data: data, address: srcAddress) else {
                            continue
                        }
                        results.append(device)
                    }

                } while Date().timeIntervalSince(start) <= timeout

                self.delegate?.discoveredDevices(results)

            } catch let error {
                self.delegate?.errorWhenDiscoveringDevices(error)
            }
        }

    }
}

public protocol SSDPServiceDelegate: class {
    func discoveredDevices(_ devices: [Device])
    func errorWhenDiscoveringDevices(_ error: Error)
}

// -9992 address already in use (Sonos app open?)
// -9992 invalid argument write is before listen (?)
