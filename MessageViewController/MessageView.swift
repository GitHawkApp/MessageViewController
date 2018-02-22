//
//  MessageView.swift
//  MessageView
//
//  Created by Ryan Nystrom on 12/20/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit

public final class MessageView: UIView, MessageTextViewListener {

    public let textView = MessageTextView()

    internal weak var delegate: MessageViewDelegate?
    internal let leftButton = UIButton()
    internal let rightButton = UIButton()
    internal let UITextViewContentSizeKeyPath = #keyPath(UITextView.contentSize)
    internal let topBorderLayer = CALayer()
    internal var contentView: UIView?
    internal var leftButtonAction: Selector?
    internal var rightButtonAction: Selector?
    public var showLeftButton: Bool = true {
        didSet {
            if !showLeftButton {
                leftButton.removeFromSuperview()
                setNeedsLayout()
            }
        }
    }

    public enum buttonType {
        case left
        case right
    }

    internal override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        if showLeftButton {
            addSubview(leftButton)
        }
        addSubview(textView)
        addSubview(rightButton)
        layer.addSublayer(topBorderLayer)

        //Set action button
        leftButton.imageEdgeInsets = .zero
        leftButton.titleEdgeInsets = .zero
        leftButton.contentEdgeInsets = .zero
        leftButton.titleLabel?.font = self.font ?? UIFont.systemFont(ofSize: 14)
        leftButton.imageView?.contentMode = .scaleAspectFit
        leftButton.imageView?.clipsToBounds = true

        // setup text view
        textView.contentInset = .zero
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
        textView.addObserver(self, forKeyPath: UITextViewContentSizeKeyPath, options: [.new], context: nil)
        textView.font = self.font ?? UIFont.systemFont(ofSize: 14)
        textView.add(listener: self)

        // setup TextKit props to defaults
        textView.textContainer.exclusionPaths = []
        textView.textContainer.maximumNumberOfLines = 0
        textView.textContainer.lineFragmentPadding = 0
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.layoutManager.hyphenationFactor = 0
        textView.layoutManager.showsInvisibleCharacters = false
        textView.layoutManager.showsControlCharacters = false
        textView.layoutManager.usesFontLeading = true

        // setup send button
        rightButton.imageEdgeInsets = .zero
        rightButton.titleEdgeInsets = .zero
        rightButton.contentEdgeInsets = .zero
        rightButton.titleLabel?.font = self.font ?? UIFont.systemFont(ofSize: 14)
        rightButton.imageView?.contentMode = .scaleAspectFit
        rightButton.imageView?.clipsToBounds = true

        updateEmptyTextStates()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        textView.removeObserver(self, forKeyPath: UITextViewContentSizeKeyPath)
    }

    // MARK: Public API

    public var font: UIFont? {
        get { return textView.font }
        set {
            textView.font = newValue
            delegate?.wantsLayout(messageView: self)
        }
    }

    public var text: String {
        get { return textView.text ?? "" }
        set {
            textView.text = newValue
            delegate?.wantsLayout(messageView: self)
            updateEmptyTextStates()
        }
    }

    public var inset: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
            delegate?.wantsLayout(messageView: self)
        }
    }

    public var buttonLeftInset: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }

    public func set(buttonIcon: UIImage?, for state: UIControlState, type: buttonType) {
        switch type {
            case .left:
                setLeft(buttonIcon: buttonIcon, for: state)
                break
            case .right:
                setRight(buttonIcon: buttonIcon, for: state)
                break
        }
        buttonLayoutDidChange()
    }

    public func set(buttonTitle: String, for state: UIControlState, type: buttonType) {
        switch type {
        case .left:
            setLeft(buttonTitle: buttonTitle, for: state)
            break
        case .right:
            setRight(buttonTitle: buttonTitle, for: state)
            break
        }
        buttonLayoutDidChange()
    }

    private func setLeft(buttonIcon: UIImage?, for state: UIControlState) {
        leftButton.setImage(buttonIcon, for: state)
    }

    private func setLeft(buttonTitle: String, for state: UIControlState) {
        leftButton.setTitle(buttonTitle, for: state)
    }

    private func setRight(buttonIcon: UIImage?, for state: UIControlState) {
        rightButton.setImage(buttonIcon, for: state)
    }

    private func setRight(buttonTitle: String, for state: UIControlState) {
        rightButton.setTitle(buttonTitle, for: state)
    }

    public var leftButtonTint: UIColor {
        get { return leftButton.tintColor }
        set {
            leftButton.tintColor = newValue
            leftButton.setTitleColor(newValue, for: .normal)
            leftButton.imageView?.tintColor = newValue
        }
    }
    public var rightButtonTint: UIColor {
        get { return rightButton.tintColor }
        set {
            rightButton.tintColor = newValue
            rightButton.setTitleColor(newValue, for: .normal)
            rightButton.imageView?.tintColor = newValue
        }
    }

    public var maxLineCount: Int = 4 {
        didSet {
            delegate?.wantsLayout(messageView: self)
        }
    }

    public func add(contentView: UIView) {
        self.contentView?.removeFromSuperview()
        assert(contentView.bounds.height > 0, "Must have a non-zero content height")
        self.contentView = contentView
        addSubview(contentView)
        setNeedsLayout()
        delegate?.wantsLayout(messageView: self)
    }

    public var keyboardType: UIKeyboardType {
        get { return textView.keyboardType }
        set { textView.keyboardType = newValue }
    }

    public func addButton(target: Any, action: Selector, type: buttonType) {
        switch type {
        case .left:
            leftButton.addTarget(target, action: action, for: .touchUpInside)
            leftButtonAction = action
            break
        case .right:
            rightButton.addTarget(target, action: action, for: .touchUpInside)
            rightButtonAction = action
            break
        }
    }

    public override var keyCommands: [UIKeyCommand]? {
        guard let action = rightButtonAction else { return nil }
        return [UIKeyCommand(input: "\r", modifierFlags: .command, action: action)]
    }

    // MARK: Overrides

    public override func layoutSubviews() {
        super.layoutSubviews()

        topBorderLayer.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY,
            width: bounds.width,
            height: 1 / UIScreen.main.scale
        )

        let safeBounds = CGRect(
            x: bounds.minX + util_safeAreaInsets.left,
            y: bounds.minY,
            width: bounds.width - util_safeAreaInsets.left - util_safeAreaInsets.right,
            height: bounds.height
        )
        let insetBounds = UIEdgeInsetsInsetRect(safeBounds, inset)

        let size = textView.font?.lineHeight ?? 25 //Use textView line height
        let leftButtonSize = CGSize(width: size, height: size)
        let rightButtonSize = rightButton.bounds.size
        
        // adjust by bottom offset so content is flush w/ text view
        let leftButtonFrame = CGRect(
            x: insetBounds.minX,
            y: (insetBounds.minY + textViewHeight) - leftButtonSize.height + leftButton.bottomHeightOffset,
            width: leftButtonSize.width,
            height: leftButtonSize.height
        )
        leftButton.frame = (showLeftButton) ? leftButtonFrame : .zero
        
        let textViewFrame = CGRect(
            x: ((showLeftButton) ? leftButtonFrame.maxX : 0) + buttonLeftInset,
            y: insetBounds.minY,
            width: insetBounds.width - ((showLeftButton) ? leftButtonSize.width : 0) - buttonLeftInset - rightButtonSize.width,
            height: textViewHeight
        )
        textView.frame = textViewFrame

        // adjust by bottom offset so content is flush w/ text view
        let rightButtonFrame = CGRect(
            x: textViewFrame.maxX + buttonLeftInset,
            y: textViewFrame.maxY - rightButtonSize.height + rightButton.bottomHeightOffset,
            width: rightButtonSize.width,
            height: rightButtonSize.height
        )
        rightButton.frame = rightButtonFrame

        let contentY = textViewFrame.maxY + inset.bottom
        contentView?.frame = CGRect(
            x: safeBounds.minX,
            y: contentY,
            width: safeBounds.width,
            height: bounds.height - contentY - util_safeAreaInsets.bottom
        )
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == UITextViewContentSizeKeyPath {
            textViewContentSizeDidChange()
        }
    }

    public override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    // MARK: Private API

    internal var height: CGFloat {
        return inset.top
            + inset.bottom
            + textViewHeight
            + (contentView?.bounds.height ?? 0)
    }

    internal var textViewHeight: CGFloat {
        return min(maxHeight, max(textView.font?.lineHeight ?? 0, textView.contentSize.height))
    }

    internal var maxHeight: CGFloat {
        return (font?.lineHeight ?? 0) * CGFloat(maxLineCount)
    }

    internal func updateEmptyTextStates() {
        let isEmpty = text.isEmpty
        rightButton.isEnabled = !isEmpty
        rightButton.alpha = isEmpty ? 0.25 : 1
    }

    internal func buttonLayoutDidChange() {
        leftButton.sizeToFit()
        rightButton.sizeToFit()
        setNeedsLayout()
    }

    internal func textViewContentSizeDidChange() {
        delegate?.sizeDidChange(messageView: self)
        textView.alwaysBounceVertical = textView.contentSize.height > maxHeight
    }

    // MARK: MessageTextViewListener

    public func didChange(textView: MessageTextView) {
        updateEmptyTextStates()
    }

    public func didChangeSelection(textView: MessageTextView) {
        delegate?.selectionDidChange(messageView: self)
    }
    
    public func willChangeRange(textView: MessageTextView, to range: NSRange) {}

}
