# Next

## Added

- **Breaking Change:** Migrated to Swift 4.2

- **Breaking Change:** Added a new delegate method to `MessageTextViewListener`, `func willChangeRange(textView: MessageTextView, to range: NSRange)` which allowed for the observation of text range changes such that the entire autocomplete string is deleted rather than character by character. [#15](https://github.com/GitHawkApp/MessageViewController/pull/15) by [@nathantannar4](https://github.com/nathantannar4)

- Added an optional `accessibilityLabel` parameter to `setButton`, and using the supplied title or image label by default. [#57](https://github.com/GitHawkApp/MessageViewController/pull/57) by [@BasThomas](https://github.com/BasThomas)

## Removed

- Removed a tap gesture recognizer on the message view that would call `becomeFirstResponder()` on the text view. [#9](https://github.com/GitHawkApp/MessageViewController/pull/9) by [@rizwankce](https://github.com/rizwankce)

## Fixed

## Miscellaneous

# 0.1.1

Initial release
