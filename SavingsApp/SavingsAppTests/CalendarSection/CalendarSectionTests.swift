//
//  CalendarSectionTests.swift
//  SavingsAppTests
//
//  Created by Hiram Castro on 03/06/24.
//

import Foundation
import XCTest
@testable import SavingsApp

final class CalendarSectionTests: XCTestCase {
    
    let vm = CalendarSectionVM()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetAllMonthsInString() throws {
        // given
        let monthsArray = vm.getMonths()
        
        // when
        
        // then
        XCTAssertNotNil(monthsArray)
        XCTAssertTrue(!monthsArray.isEmpty)
    }
    
    func testGetRangeOfYear() throws {
        // given
        let rangeOfYearsArray = vm.getRangeOfYear()
        // when
        
        // then
        XCTAssertNotNil(rangeOfYearsArray)
        XCTAssertTrue(rangeOfYearsArray.count > 0)
    }
    
    func testValidateCustomDateConverter() throws  {
        // given
        let month = "Jun"
        let year = 2024
        
        // when
        var dateText = "\(month), \(year)"
        let currentDate = dateText.convertToDate()
        
        // then
        XCTAssertNotNil(currentDate)
    }


}
