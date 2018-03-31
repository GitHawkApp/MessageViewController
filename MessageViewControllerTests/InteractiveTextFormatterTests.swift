//
//  InteractiveTextFormatterTests.swift
//  MessageViewControllerTests
//
//  Created by Viktoras Laukevičius on 31/03/2018.
//  Copyright © 2018 Ryan Nystrom. All rights reserved.
//

import XCTest
@testable import MessageViewController

private func generateList(withDelimiter d: String) -> String {
    return "\(d) Item A\n\(d) Item B"
}

class InteractiveTextFormatterTests: XCTestCase {
    
    var formatter: InteractiveTextFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = InteractiveTextFormatter()
    }
    
    override func tearDown() {
        formatter = nil
        super.tearDown()
    }
    
    func test_continuesNumberedList_whenAtTheEnd() {
        let str = "1. Item A\n2. Item B"
        let attrStr = NSAttributedString(string: str)
        let text = formatter.applying(change: "\n", in: attrStr, in: NSRange(location: str.count, length: 0))?.0
        XCTAssertEqual(text?.string, "\(str)\n3. ")
    }
    
    func test_ignoresIncrement_whenReallyLongList() {
        let maxInt = Int.max
        let str = "\(maxInt - 1). Item A \n\(maxInt). Item B"
        let attrStr = NSAttributedString(string: str)
        let text = formatter.applying(change: "\n", in: attrStr, in: NSRange(location: str.count, length: 0))?.0
        XCTAssertNil(text)
    }
    
    func test_continuesNumberedList_whenInTheMiddle() {
        let str1 = "1. Item A \n2. Item B"
        let str2 = "\nContinues..."
        let attrStr = NSAttributedString(string: "\(str1)\(str2)")
        let text = formatter.applying(change: "\n", in: attrStr, in: NSRange(location: str1.count, length: 0))?.0
        XCTAssertEqual(text?.string, "\(str1)\n3. \(str2)")
    }
    
    func test_continuesList_whenUsedAsterisks() {
        let str = generateList(withDelimiter: "*")
        let text = formatter.applying(change: "\n", in: NSAttributedString(string: str), in: NSRange(location: str.count, length: 0))?.0
        XCTAssertEqual(text?.string, "\(str)\n* ")
    }
    
    func test_continuesList_whenUsedMinuses() {
        let str = generateList(withDelimiter: "-")
        let text = formatter.applying(change: "\n", in: NSAttributedString(string: str), in: NSRange(location: str.count, length: 0))?.0
        XCTAssertEqual(text?.string, "\(str)\n- ")
    }
    
    func test_continuesList_whenUsedPuses() {
        let str = generateList(withDelimiter: "+")
        let text = formatter.applying(change: "\n", in: NSAttributedString(string: str), in: NSRange(location: str.count, length: 0))?.0
        XCTAssertEqual(text?.string, "\(str)\n+ ")
    }
    
    func test_preservesAttributes_whenTextPrefilled() {
        let str = generateList(withDelimiter: "-")
        let attrs: [NSAttributedStringKey : AnyHashable] = [NSAttributedStringKey.baselineOffset : 3]
        let attrStr = NSAttributedString(string: str, attributes: attrs)
        let text = formatter.applying(change: "\n", in: attrStr, in: NSRange(location: str.count, length: 0))?.0
        let resultAttrs = text?.attributes(at: str.count + 2, effectiveRange: nil) as? [NSAttributedStringKey : AnyHashable]
        XCTAssertEqual(resultAttrs!, attrs)
    }
    
    func test_adjustsSelectionPosition_whenTextAppended() {
        let str = generateList(withDelimiter: "-")
        let selectionBeginning = formatter.applying(change: "\n", in: NSAttributedString(string: str), in: NSRange(location: str.count, length: 0))?.1
        let appended = "\n- "
        XCTAssertEqual(selectionBeginning, str.count + appended.count)
    }
    
    func test_adjustsSelectionPosition_whenTextInserted() {
        let str1 = generateList(withDelimiter: "-")
        let str2 = "\nContinues..."
        let selectionBeginning = formatter.applying(change: "\n", in: NSAttributedString(string: "\(str1)\(str2)"), in: NSRange(location: str1.count, length: 0))?.1
        let inserted = "\n- "
        XCTAssertEqual(selectionBeginning, str1.count + inserted.count)
    }
    
    func test_notContinuesList_whenLineNotListItem() {
        let str = generateList(withDelimiter: "-") + "\nContinues..."
        let text = formatter.applying(change: "\n", in: NSAttributedString(string: str), in: NSRange(location: str.count, length: 0))?.0
        XCTAssertNil(text)
    }
}
