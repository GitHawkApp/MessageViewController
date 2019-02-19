//
//  MessageTextViewTests.swift
//  MessageViewControllerTests
//
//  Created by Ryan Nystrom on 10/29/18.
//  Copyright © 2018 Ryan Nystrom. All rights reserved.
//

import XCTest
@testable import MessageViewController

class TestListener: MessageTextViewListener {
    var didChange = 0
    func didChange(textView: MessageTextView) {
        didChange += 1
    }

    var didChangeSelection = 0
    func didChangeSelection(textView: MessageTextView) {
        didChangeSelection += 1
    }

    var willChangeRange = 0
    func willChangeRange(textView: MessageTextView, to range: NSRange) {
        willChangeRange += 1
    }
}

class MessageTextViewTests: XCTestCase {

    func test_listenersReleased() {
        let view = MessageTextView()
        autoreleasepool {
            let listeners = [TestListener(), TestListener()]
            listeners.forEach { view.add(listener: $0 ) }
            var count = 0
            view.enumerateListeners { _ in
                count += 1
            }
            XCTAssertEqual(count, 2)
        }
        var count = 0
        view.enumerateListeners { _ in
            count += 1
        }
        XCTAssertEqual(count, 0)
    }

    func test_didChange() {
        let listeners = [TestListener(), TestListener()]
        let view = MessageTextView()
        listeners.forEach { view.add(listener: $0 ) }
        view.textViewDidChange(view)
        XCTAssertEqual(listeners[0].didChange, 1)
        XCTAssertEqual(listeners[1].didChange, 1)
        XCTAssertEqual(listeners[0].didChangeSelection, 0)
        XCTAssertEqual(listeners[1].didChangeSelection, 0)
        XCTAssertEqual(listeners[0].willChangeRange, 0)
        XCTAssertEqual(listeners[1].willChangeRange, 0)
    }

    func test_didChangeSelection() {
        let listeners = [TestListener(), TestListener()]
        let view = MessageTextView()
        listeners.forEach { view.add(listener: $0 ) }
        view.textViewDidChangeSelection(view)
        XCTAssertEqual(listeners[0].didChange, 0)
        XCTAssertEqual(listeners[1].didChange, 0)
        XCTAssertEqual(listeners[0].didChangeSelection, 1)
        XCTAssertEqual(listeners[1].didChangeSelection, 1)
        XCTAssertEqual(listeners[0].willChangeRange, 0)
        XCTAssertEqual(listeners[1].willChangeRange, 0)
    }

    func test_shouldChange() {
        let listeners = [TestListener(), TestListener()]
        let view = MessageTextView()
        listeners.forEach { view.add(listener: $0 ) }
        XCTAssertTrue(view.textView(view, shouldChangeTextIn: NSRange(), replacementText: ""))
        XCTAssertEqual(listeners[0].didChange, 0)
        XCTAssertEqual(listeners[1].didChange, 0)
        XCTAssertEqual(listeners[0].didChangeSelection, 0)
        XCTAssertEqual(listeners[1].didChangeSelection, 0)
        XCTAssertEqual(listeners[0].willChangeRange, 1)
        XCTAssertEqual(listeners[1].willChangeRange, 1)
    }

    func test_setText() {
        let listeners = [TestListener(), TestListener()]
        let view = MessageTextView()
        listeners.forEach { view.add(listener: $0 ) }
        view.text = "foo bar"
        view.text = "foo"
        view.text = ""
        view.text = ""
        XCTAssertEqual(listeners[0].didChange, 3)
        XCTAssertEqual(listeners[1].didChange, 3)
        XCTAssertEqual(listeners[0].didChangeSelection, 3)
        XCTAssertEqual(listeners[1].didChangeSelection, 3)
        XCTAssertEqual(listeners[0].willChangeRange, 0)
        XCTAssertEqual(listeners[1].willChangeRange, 0)
    }

    func test_setAttributedText() {
        let listeners = [TestListener(), TestListener()]
        let view = MessageTextView()
        listeners.forEach { view.add(listener: $0 ) }
        view.attributedText = NSAttributedString(string: "foo bar")
        view.attributedText = NSAttributedString(string: "foo")
        view.attributedText = NSAttributedString(string: "")
        view.attributedText = NSAttributedString(string: "")
        XCTAssertEqual(listeners[0].didChange, 3)
        XCTAssertEqual(listeners[1].didChange, 3)
        XCTAssertEqual(listeners[0].didChangeSelection, 3)
        XCTAssertEqual(listeners[1].didChangeSelection, 3)
        XCTAssertEqual(listeners[0].willChangeRange, 0)
        XCTAssertEqual(listeners[1].willChangeRange, 0)
    }

    func test_settingFontUpdatesDefaultFont() {
        let view = MessageTextView()
        let font = UIFont.systemFont(ofSize: 60)
        view.font = font
        XCTAssertEqual(view.defaultFont, font)
        XCTAssertEqual(view.defaultTextAttributes[.font] as! UIFont, font)
    }

    func test_settingTextColorUpdatesDefaultTextColor() {
        let view = MessageTextView()
        let color = UIColor.red
        view.textColor = color
        XCTAssertEqual(view.defaultTextColor, color)
        XCTAssertEqual(
            view.defaultTextAttributes[NSAttributedString.Key.foregroundColor] as! UIColor,
            color
        )
    }

    func test_settingTextUpdatesPlaceholder() {
        let view = MessageTextView()
        view.text = ""
        XCTAssertFalse(view.placeholderLabel.isHidden)
        view.text = "foo"
        XCTAssertTrue(view.placeholderLabel.isHidden)
        view.text = ""
        XCTAssertFalse(view.placeholderLabel.isHidden)
    }

    func test_settingAttributedTextUpdatesPlaceholder() {
        let view = MessageTextView()
        view.attributedText = NSAttributedString(string: "")
        XCTAssertFalse(view.placeholderLabel.isHidden)
        view.attributedText = NSAttributedString(string: "foo")
        XCTAssertTrue(view.placeholderLabel.isHidden)
        view.attributedText = NSAttributedString(string: "")
        XCTAssertFalse(view.placeholderLabel.isHidden)
    }

    func test_settingPlaceholderProperties() {
        let view = MessageTextView()
        view.placeholderText = "foo"
        XCTAssertEqual(view.placeholderLabel.text, "foo")
        view.placeholderTextColor = .red
        XCTAssertEqual(view.placeholderLabel.textColor, .red)
    }

    func test_settingDefaultsUpdatesTypingAttributes() {
        let view = MessageTextView()
        XCTAssertEqual(
            view.typingAttributes[NSAttributedString.Key.font] as! UIFont,
            view.defaultFont
        )
        XCTAssertEqual(
            view.typingAttributes[NSAttributedString.Key.foregroundColor] as! UIColor,
            view.defaultTextColor
        )
        let font = UIFont.systemFont(ofSize: 60)
        let color = UIColor.red
        view.defaultFont = font
        view.defaultTextColor = color
        XCTAssertEqual(
            view.typingAttributes[NSAttributedString.Key.font] as! UIFont,
            font
        )
        XCTAssertEqual(
            view.typingAttributes[NSAttributedString.Key.foregroundColor] as! UIColor,
            color
        )
    }
}

