//
//  WaterMyPlantsTests.swift
//  WaterMyPlantsTests
//
//  Created by Shawn James on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import XCTest
@testable import WaterMyPlants

class WaterMyPlantsTests: XCTestCase {
    
    var plantController: PlantController?
    
    func testGettingData() {
        let expectation = self.expectation(description: "\(#file), \(#function): WaitForGenericGetResult")
        let networkService = NetworkService()
        
        let request = networkService.createRequest(url: URL(string:"https://water-my-plants-buildweek.herokuapp.com/api"), method: .get)
        
        XCTAssertNotNil(request)
        
        networkService.dataLoader.loadData(using: request!) { data, response, error in
            XCTAssertNil(error)
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 404)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testUserCreate() {
        let user = UserRepresentation( username: "usertest", password: "new", phoneNumber: "555-555-5555", identifier: 1)
        if user.identifier == 1,
            user.username == "usertest",
            user.password == "new",
            user.phoneNumber == "555-555-5555" {
            XCTAssert(user.identifier == 1)
            XCTAssert(user.username == "usertest")
            XCTAssert(user.password == "new")
            XCTAssert(user.phoneNumber == "555-555-5555")
        }
    }

}
