//
//  SSDPServiceTests.swift
//  SSDPServiceTests
//
//  Created by Nathan Wong on 13/01/2017.
//  Copyright © 2017 Nathan Wong. All rights reserved.
//

@testable import SSDPService
import XCTest

class SSDPServiceTests: XCTestCase {

    var anExpectation: XCTestExpectation? = nil

    func testFunction() {

        anExpectation = expectation(description: "xx")

        let client = SSDPService(serviceType: "urn:schemas-upnp-org:device:ZonePlayer:1")
        client.delegate = self
        client.search()

        waitForExpectations(timeout: 100, handler: nil)
    }
}

extension SSDPServiceTests: SSDPServiceDelegate {

    func discoveredDevices(_ devices: [Device]) {
        print(devices)
        anExpectation?.fulfill()
    }

    func errorWhenDiscoveringDevices(_ error: Error) {
        print(error.localizedDescription)
    }
}
