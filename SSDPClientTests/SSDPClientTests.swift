//
//  SSDPClientTests.swift
//  SSDPClientTests
//
//  Created by Nathan Wong on 13/01/2017.
//  Copyright © 2017 Nathan Wong. All rights reserved.
//

@testable import SSDPClient
import XCTest

class SSDPClientTests: XCTestCase {
    func testFunction() {
        let client = SSDPClient(serviceType: "urn:schemas-upnp-org:device:ZonePlayer:1")
        client.search()

        let anExpectation = expectation(description: "xx")
        waitForExpectations(timeout: 100, handler: nil)
    }
}
