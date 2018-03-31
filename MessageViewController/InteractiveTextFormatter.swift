//
//  InteractiveTextFormatter.swift
//  MessageViewController
//
//  Created by Viktoras Laukevičius on 31/03/2018.
//  Copyright © 2018 Ryan Nystrom. All rights reserved.
//

import Foundation

private extension NSAttributedString {
    func replacingCharactersWithReplacementsBeginning(in range: NSRange, with: String, attributes: [NSAttributedStringKey : Any]) -> (NSAttributedString, Int) {
        let attrStr = self.replacingCharacters(in: range, with: NSAttributedString(string: with, attributes: attributes))
        return (attrStr, range.upperBound + with.count)
    }
}

internal final class InteractiveTextFormatter {
    
    func applying(change: String, in attrText: NSAttributedString, in range: NSRange) -> (NSAttributedString, Int)? {
        // currently supports only if a single (new line) character is typed
        guard change == "\n" else { return nil }
        
        let rangeBegin = attrText.string.index(attrText.string.startIndex, offsetBy: range.lowerBound)
        let textUpToChangeLoc = attrText.string.prefix(upTo: rangeBegin)
        guard let lastLine = textUpToChangeLoc.components(separatedBy: "\n").last, lastLine.count != 0 else { return nil }
        
        // it's safe to get attributes of text at specified location because
        // not empty components list ensures that the text is not empty
        let textAttrs = attrText.attributes(at: range.lowerBound - 1, effectiveRange: nil)
        
        if let unorderedPrefix = ["* ", "- ", "+ "].first(where: lastLine.starts) {
            return attrText.replacingCharactersWithReplacementsBeginning(in: range, with: "\n\(unorderedPrefix)", attributes: textAttrs)
        } else if let candidate = lastLine.components(separatedBy: " ").first, candidate.hasSuffix("."), let intVal = Int(candidate.prefix(candidate.count - 1)) {
            guard intVal &+ 1 > intVal else {
                // wow, someone created a really long list
                return nil
            }
            return attrText.replacingCharactersWithReplacementsBeginning(in: range, with: "\n\(intVal + 1). ", attributes: textAttrs)
        } else {
            return nil
        }
    }
}
