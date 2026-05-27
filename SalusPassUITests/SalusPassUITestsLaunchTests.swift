//
//  SalusPassUITestsLaunchTests.swift
//  SalusPassUITestsLaunchTests
//
//  Created by Tom Brophy on 10/03/2026.
//

import XCTest

final class SalusPassUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchAndVerifyUI() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-uitesting")
        app.launch()

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 5.0))

        // This is to verify the Add New Account
        let mainList = app.collectionViews["MainList"]
        if !mainList.waitForExistence(timeout: 20) {
            let sidebarButton = app.buttons["Sidebar"].exists ? app.buttons["Sidebar"] : app.navigationBars.buttons.firstMatch
            if sidebarButton.waitForExistence(timeout: 5) && sidebarButton.isHittable {
                sidebarButton.tap()
            }
        }

        let titlePredicate = NSPredicate(format: "label CONTAINS 'SalusPass'")
        let universalTitle = app.descendants(matching: .any).matching(titlePredicate).firstMatch

        XCTAssertTrue(universalTitle.waitForExistence(timeout: 10), "The SalusPass title is missing.")

        //This is to verify the section header
        let sectionHeader = app.staticTexts["Add New Account"].firstMatch
        XCTAssertTrue(sectionHeader.waitForExistence(timeout: 5), "The section header is missing.")

        // This is to verify the email generator button exists.
        let emailIcon = app.buttons["at.badge.plus_menu"].firstMatch
        XCTAssertTrue(emailIcon.waitForExistence(timeout: 5), "The email generator button is missing.")

        // This is to take the screenshot.
        let attachment = XCTAttachment(screenshot: app.screenshot())
        let orientation = XCUIDevice.shared.orientation.isLandscape ? "Landscape" : "Portrait"
        attachment.name = "Launch Screen - \(orientation)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
