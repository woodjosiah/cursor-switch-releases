import SwiftUI

/// Enforce one extended grapheme in the native editor itself. Sanitizing only
/// the model can leave NSTextField's editing buffer showing several emoji.
struct SingleEmojiInput: NSViewRepresentable {
    @Binding var text: String

    nonisolated static func normalized(_ input: String) -> String {
        input.trimmingCharacters(in: .whitespacesAndNewlines).last.map(String.init) ?? ""
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSStackView {
        let field = NSTextField(string: text)
        field.placeholderString = "Choose one emoji"
        field.isBezeled = true
        field.bezelStyle = .roundedBezel
        field.isEditable = true
        field.isSelectable = true
        field.cell?.usesSingleLineMode = true
        field.font = .systemFont(ofSize: NSFont.systemFontSize)
        field.setAccessibilityLabel("Emoji")
        field.delegate = context.coordinator
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        context.coordinator.field = field
        let button = NSButton(title: "Emoji & Symbols…", target: context.coordinator,
                              action: #selector(Coordinator.chooseEmoji))
        button.bezelStyle = .rounded
        button.setContentHuggingPriority(.required, for: .horizontal)
        let stack = NSStackView(views: [field, button])
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = 8
        return stack
    }

    func updateNSView(_ view: NSStackView, context: Context) {
        context.coordinator.parent = self
        guard let field = context.coordinator.field,
              field.stringValue != text,
              (field.currentEditor() as? NSTextView)?.hasMarkedText() != true else { return }
        field.stringValue = text
        field.currentEditor()?.string = text
    }

    @MainActor
    final class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: SingleEmojiInput
        weak var field: NSTextField?

        init(_ parent: SingleEmojiInput) { self.parent = parent }

        @objc func chooseEmoji() {
            guard let field else { return }
            field.window?.makeFirstResponder(field)
            field.selectText(nil)
            NSApp.orderFrontCharacterPalette(nil)
        }

        func controlTextDidChange(_ notification: Notification) { normalizeEditor() }
        func controlTextDidEndEditing(_ notification: Notification) { normalizeEditor() }

        private func normalizeEditor() {
            guard let field else { return }
            let editor = field.currentEditor() as? NSTextView
            guard editor?.hasMarkedText() != true else { return }
            let value = SingleEmojiInput.normalized(field.stringValue)
            if field.stringValue != value { field.stringValue = value }
            if let editor, editor.string != value {
                editor.string = value
                editor.setSelectedRange(NSRange(location: value.utf16.count, length: 0))
            }
            parent.text = value
        }
    }
}
