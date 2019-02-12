//
//  NSAttributedString+HighlightingTests.swift
//  MessageViewControllerTests
//
//  Created by Nathan Tannar on 2/1/18.
//  Copyright © 2018 Ryan Nystrom. All rights reserved.
//

import XCTest
import MessageViewController

class NSAttributedString_HighlightingTests: XCTestCase {
    
    var controller: MessageAutocompleteController?
    var textView: MessageTextView?
    
    /// A key used for referencing which substrings were autocompletes
    private let NSAttributedAutocompleteKey = NSAttributedString.Key.init("com.messageviewcontroller.autocompletekey")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        textView = MessageTextView()
        controller = MessageAutocompleteController(textView: textView!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        controller = nil
        textView = nil
        
        super.tearDown()
    }
    
    func test_TailHighlight() {
        
        guard let textView = textView else { return XCTAssert(false, "textView nil") }
        guard let controller = controller else { return XCTAssert(false, "controller nil") }
        
        let prefix = "@"
        controller.register(prefix: prefix)
        
        let nonAttributedText = "Some text " + prefix
        textView.attributedText = NSAttributedString(string: nonAttributedText)
        controller.didChangeSelection(textView: textView)
        guard controller.selection != nil else {
            return XCTAssert(false, "Selection nil")
        }
        let autocompleteText = "username"
        controller.accept(autocomplete: autocompleteText)
        let range = NSRange(location: nonAttributedText.count - 1, length: autocompleteText.count)
        let attributes = textView.attributedText.attributes(at: range.lowerBound, longestEffectiveRange: nil, in: range)
        guard let isAutocompleted = attributes[NSAttributedAutocompleteKey] as? Bool else {
            return XCTAssert(false, attributes.debugDescription)
        }
        XCTAssert(isAutocompleted, attributes.debugDescription)
    }
    
    func test_HeadHighlight() {
        
        guard let textView = textView else { return XCTAssert(false, "textView nil") }
        guard let controller = controller else { return XCTAssert(false, "controller nil") }
        
        let prefix = "@"
        controller.register(prefix: prefix)
        
        let nonAttributedText = prefix
        textView.attributedText = NSAttributedString(string: nonAttributedText)
        controller.didChangeSelection(textView: textView)
        guard controller.selection != nil else {
            return XCTAssert(false, "Selection nil")
        }
        let autocompleteText = "username"
        controller.accept(autocomplete: autocompleteText)
        
        let highlightRange = NSRange(location: nonAttributedText.count - 1, length: autocompleteText.count)
        let attributes = textView.attributedText.attributes(at: highlightRange.lowerBound, longestEffectiveRange: nil, in: highlightRange)
        guard let isAutocompleted = attributes[NSAttributedAutocompleteKey] as? Bool else {
            return XCTAssert(false, attributes.debugDescription)
        }
        XCTAssert(isAutocompleted, attributes.debugDescription)
    }
    
}

