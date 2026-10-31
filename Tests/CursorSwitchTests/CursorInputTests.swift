import Testing
@testable import CursorSwitch

struct CursorInputTests {
    @Test func emojiInputReplacesRatherThanAccumulates() {
        #expect(SingleEmojiInput.normalized("👻✨") == "✨")
        #expect(SingleEmojiInput.normalized("🌸 🐈 🦋") == "🦋")
        #expect(SingleEmojiInput.normalized("  ") == "")
    }

    @Test func emojiInputKeepsComplexGraphemesIntact() {
        #expect(SingleEmojiInput.normalized("👻👩🏽‍💻") == "👩🏽‍💻")
        #expect(SingleEmojiInput.normalized("🇺🇸") == "🇺🇸")
        #expect(SingleEmojiInput.normalized("👨‍👩‍👧‍👦") == "👨‍👩‍👧‍👦")
    }

    @Test func symbolSearchAcceptsPlainLanguage() {
        let paw = SymbolChoice.choices.first { $0.name == "pawprint.fill" }!
        #expect(paw.matches("cat"))
        #expect(paw.matches("PET paw"))
        #expect(!paw.matches("airplane"))
        let hand = SymbolChoice.choices.first { $0.name == "hand.point.up.fill" }!
        #expect(hand.matches("pointing hand"))
        #expect(hand.matches("link"))
    }
}
