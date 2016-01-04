//
//  Whatgoeswith_UITests.swift
//  Whatgoeswith_UITests
//
//  Created by Paul Shapiro on 1/4/16.
//  Copyright © 2016 Lunarpad Corporation. All rights reserved.
//

import XCTest

class Whatgoeswith_UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_screenshot_homepage() {
        // Use recording to get started writing UI tests.
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            // Simulate a tap to create a breakpoint in case this install doesn't have a banner showing (already installed)
            XCUIApplication()
                .staticTexts["Start typing ingredients and I'll find you something\u{00a0}special.\n\nTap suggested pairings to expand your\u{00a0}recipe."]
                .tap()
            
            // Use XCTAssert and related functions to verify your tests produce the correct results.
        }
    }
    
}
