# Next

## Added

- **Breaking Change:** Added a new delegate method to `MessageTextViewListener`, `func willChangeRange(textView: MessageTextView, to range: NSRange)` which allowed for the observation of text range changes such that the entire autocomplete string is deleted rather than character by character. [#15](https://github.com/GitHawkApp/MessageViewController/pull/15) by [@nathantannar4](https://github.com/nathantannar4)

## Removed

- Removed a tap gesture recognizer on the message view that would call `becomeFirstResponder()` on the text view. [#9](https://github.com/GitHawkApp/MessageViewController/pull/9) by [@rizwankce](https://github.com/rizwankce)

## Fixed

## Miscellaneous

# 0.1.1

Initial release
