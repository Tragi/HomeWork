//
//  PersonalNotesTests.swift
//  PersonalNotesTests
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import XCTest
@testable import PersonalNotes

class PersonalNotesTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAPI() {
        let dataService = APIService()
        let message = "Buy cheese and bread for breakfast."
        let expectation = XCTestExpectation(description: "API")
        
        dataService.createNote(title: message) { (note, error) in
            XCTAssert(message == note?.title)
            dataService.notes { (notes, error) in
                XCTAssert(notes?.contains(where: {$0.id == note?.id}) == true)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }


}
