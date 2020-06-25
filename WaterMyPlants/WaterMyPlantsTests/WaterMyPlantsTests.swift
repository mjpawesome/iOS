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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
