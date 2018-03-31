//
//  ResolverTests.swift
//  ResolverTests
//
//  Created by Michael Long on 11/14/17.
//  Copyright © 2017 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverBasicTests: XCTestCase {

    var resolver: Resolver!

    override func setUp() {
        super.setUp()
        resolver = Resolver()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRegistrationAndExplicitResolution() {
        resolver.register { XYZSessionService() }
        let session: XYZSessionService? = resolver.resolve(XYZSessionService.self)
        XCTAssertNotNil(session)
    }

    func testRegistrationAndInferedResolution() {
        resolver.register { XYZSessionService() }
        let session: XYZSessionService? = resolver.resolve() as XYZSessionService
        XCTAssertNotNil(session)
    }

    func testRegistrationAndOptionalResolution() {
        resolver.register { XYZSessionService() }
        let session: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(session)
    }

    func testRegistrationAndOptionalResolutionFailure() {
        let session: XYZSessionService? = resolver.optional()
        XCTAssertNil(session)
    }

    func testRegistrationAndResolutionChain() {
        resolver.register { XYZSessionService() }
        resolver.register { XYZService( self.resolver.optional() ) }
        let service: XYZService? = resolver.optional()
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session)
    }

    func testRegistrationOverwritting() {
        resolver.register() { XYZNameService("Fred") }
        resolver.register() { XYZNameService("Barney") }
        let service: XYZNameService? = resolver.optional()
        XCTAssertNotNil(service)
        XCTAssert(service?.name == "Barney")
    }

    func testRegistrationAndResolutionArguments() {
        resolver.register { XYZSessionService() }
        resolver.register { (r, a) -> XYZService in
            XCTAssert( (a as? Bool) ?? false )
            return XYZService( r.optional() )
        }
        let service: XYZService? = resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session)
    }

    func testRegistrationAndResolutionProperties() {
        resolver.register { XYZSessionService() }
            .resolveProperties { (r, s) in
                s.name = "updated"
        }
        let session: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(session)
        XCTAssert(session?.name == "updated")
    }

    func testRegistrationAndResolutionPropertiesArgs() {
        resolver.register { XYZSessionService() }
            .resolveProperties { (r, s, a) in
                XCTAssert( (a as? Bool) ?? false )
                s.name = "updated"
            }
        let session: XYZSessionService? = resolver.optional(args: true)
        XCTAssertNotNil(session)
        XCTAssert(session?.name == "updated")
    }

    func testRegistrationAndResolutionResolve() {
        resolver.register { XYZSessionService() }
        let session: XYZSessionService = resolver.resolve()
        XCTAssertNotNil(session)
    }

    func testRegistrationAndResolutionResolveArgs() {
        let service: XYZService = Resolver.resolve(args: true)
        XCTAssertNotNil(service.session)
    }
}