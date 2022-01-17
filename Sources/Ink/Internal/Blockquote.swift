/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Blockquote: Fragment {
    var modifierTarget: Modifier.Target { .blockquotes }
    
    private var lines = [FormattedText]()

    static func read(using reader: inout Reader) throws -> Blockquote {
        try reader.read(">")
        try reader.readWhitespaces()

        var lines = [FormattedText.readLine(using: &reader)]

        while !reader.didReachEnd {
            switch reader.currentCharacter {
            case \.isNewline:
                return Blockquote(lines: lines)
            case ">":
                reader.advanceIndex()
                if !reader.currentCharacter.isNewline {
                    try reader.readWhitespaces()
                }
            default:
                break
            }

            lines.append(FormattedText.readLine(using: &reader))
        }

        return Blockquote(lines: lines)
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let body = lines.reduce("", { partialResult, formatedText in
            partialResult + "<p>" + formatedText.html(usingURLs: urls, modifiers: modifiers) + "</p>"
        })
        return "<blockquote>\(body)</blockquote>"
    }

    func plainText() -> String {
        lines.map { $0.plainText() }.joined(separator: "\n")
    }
}
