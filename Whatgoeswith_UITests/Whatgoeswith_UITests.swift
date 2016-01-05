//
//  Whatgoeswith_UITests.swift
//  Whatgoeswith_UITests
//
//  Created by Paul Shapiro on 1/4/16.
//  Copyright © 2016 Lunarpad Corporation. All rights reserved.
//

import XCTest

class Whatgoeswith_UITests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_01_onboarding()
    {
        sleep(3); // wait for banner to pop; we're assuming this was a fresh install; wait for images to be downloaded
        
        snapshot("01_Onboarding")
    }
    
    func test_02_explore()
    {
        let whatGoesWithTextField = XCUIApplication().textFields["What goes with\u{2026}?"]
        whatGoesWithTextField.tap()
        whatGoesWithTextField.typeText("bonito flakes")
        
        sleep(4); // wait for images to be downloaded
        
        snapshot("02_Explore")
    }
    
    func test_03_dinner()
    {
        
        let whatGoesWithTextField = XCUIApplication().textFields["What goes with\u{2026}?"]
        whatGoesWithTextField.tap()
        whatGoesWithTextField.typeText("swordfish, lemon juice, garlic, broad beans")
        
        sleep(4); // wait for images to be downloaded

        snapshot("03_Dinner")
    }
    
    func test_04_mixologist()
    {
        let whatGoesWithTextField = XCUIApplication().textFields["What goes with\u{2026}?"]
        whatGoesWithTextField.tap()
        whatGoesWithTextField.typeText("bourbon, simple syrup, mint")
        
        sleep(4); // wait for images to be downloaded
        
        snapshot("04_Mixologist")
    }
    
}
