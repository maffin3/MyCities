//
//  MyCitiesNetworkingTests.swift
//  MyCitiesTests
//
//  Created by Maciej Czech on 08/10/2020.
//

import XCTest
@testable import MyCities

class MyCitiesNetworkingTests: XCTestCase {

    var sut: CityNetJSONStack!
    
    override func setUpWithError() throws {
        super.setUp()
        sut = CityNetJSONStack()
        
    }

    override func tearDownWithError() throws {
        sut = nil
        super.tearDown()
    }

    func testMainJSONDownload() throws {
        
        var citiesData:[CityData]?
        var baseUrl:String?
        var errMessage:String?
        
        let promise = expectation(description: "Completion handler invoked")

        sut.getCitiesData { (returnedCities, imageBaseUrl, errorMessage) in
            citiesData = returnedCities
            baseUrl = imageBaseUrl
            errMessage = errorMessage
            
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 30)
        
        // then
        XCTAssertNil(errMessage)
        XCTAssertNotNil(citiesData)
        XCTAssertNotNil(baseUrl)
        XCTAssertNotEqual(citiesData?.count, 0)
        
    }

    func testCityDetailsJSONDownload() throws {
        
        var visitorsData:CityDetail1Data?
        var ratingData: CityDetail2Data?
        var errMessage: String?
        
        let promise = expectation(description: "Completion handler invoked")
        
        sut.getCityDetails{ (detail1, detail2, errorMessage) in
            visitorsData = detail1
            ratingData = detail2
            errMessage = errorMessage
            
            promise.fulfill()
        }

        wait(for: [promise], timeout: 30)
        
        // then
        XCTAssertNotNil(errMessage)
        XCTAssertEqual(errMessage, "")
        XCTAssertNotNil(visitorsData)
        XCTAssertNotNil(ratingData)

    }
    
}
