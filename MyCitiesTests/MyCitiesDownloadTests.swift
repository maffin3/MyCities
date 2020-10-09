//
//  MyCitiesDownloadTests.swift
//  MyCitiesTests
//
//  Created by Maciej Czech on 08/10/2020.
//

import XCTest
@testable import MyCities

class MyCitiesDownloadTests: XCTestCase {

    var sut: CityNetDownloadStack!
    var spy: CityDownloadSpy!

    override func setUpWithError() throws {
        super.setUp()
        spy = CityDownloadSpy()
        sut = CityNetDownloadStack(imgBaseUrlString: "https://maffin3.s3.amazonaws.com/img", delegate: spy, bgSessionId: "pl.controlsoft.MyCities.testSession")
    }

    override func tearDownWithError() throws {
        sut = nil
        spy = nil
        print("tear down")
        super.tearDown()
    }

    func testDownloadingCityImage() throws {

        let promise = expectation(description: "Completion handler invoked")
        spy.asyncExpectation = promise

        // selected cityId which has city photo on server for sure
        sut.downloadImageFor(city: CityData(cityId: Int(6), cityName: "Does not matter", country: "Does not matter"), force:true)
        
        wait(for: [promise], timeout: 10)
        
        // then
        guard let cityIdResult = spy.cityIdResult else {
            XCTFail("Expected delegate to be called")
            return
        }

        XCTAssertEqual(cityIdResult, Int(6))

    }


}

class CityDownloadSpy: CityNetDownloadStackDelegate {
    
    private(set) var cityIdResult:Int?
    var asyncExpectation: XCTestExpectation?

    func cityImageDidDownloadFor(cityId: Int) {
        guard let expectation = self.asyncExpectation else {
          XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
          return
        }

        print("spy delegate")
        self.cityIdResult = cityId
        expectation.fulfill()
    }

}

