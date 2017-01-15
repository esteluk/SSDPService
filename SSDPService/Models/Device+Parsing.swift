//
//  Device+Parsing.swift
//  SSDPService
//
//  Created by Nathan Wong on 13/01/2017.
//  Copyright © 2017 Nathan Wong. All rights reserved.
//

import Socket

extension Device {
    static func parse(data: Data, address: Socket.Address?) -> Device? {
        guard let address = address,
            let responseString = String(data: data, encoding: .utf8) else {
                return nil
        }
        let components = responseString.components(separatedBy: "\r\n")

        var resultDict = [String: String]()

        for component in components {
            let subComponents = component.components(separatedBy: ": ")
            guard subComponents.count == 2 else {
                continue
            }

            resultDict[subComponents[0]] = subComponents[1]
        }

        guard let ipAddress = Socket.hostnameAndPort(from: address)?.hostname,
            let description = resultDict["LOCATION"],
            let server = resultDict["SERVER"],
            let serviceType = resultDict["ST"],
            let usn = resultDict["USN"] else {
                return nil
        }

        return Device(ipAddress: ipAddress, descriptionUrl: description, server: server, serviceType: serviceType, usn: usn)
    }
}
