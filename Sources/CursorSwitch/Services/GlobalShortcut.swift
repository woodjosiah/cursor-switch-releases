import Carbon

/// A registered hot key needs neither an event tap nor Accessibility permission.
@MainActor
final class GlobalShortcut {
    private var hotKey: EventHotKeyRef?
    private var handler: EventHandlerRef?

    func register() -> Bool {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let status = InstallEventHandler(GetApplicationEventTarget(), { _, event, _ in
            guard let event else { return OSStatus(eventNotHandledErr) }
            var identifier = EventHotKeyID()
            let result = GetEventParameter(event, EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &identifier)
            guard result == noErr, identifier.signature == 0x43535754, identifier.id == 1 else {
                return OSStatus(eventNotHandledErr)
            }
            Task { @MainActor in CursorStore.shared.toggle() }
            return noErr
        }, 1, &eventType, nil, &handler)
        guard status == noErr else { return false }
        let identifier = EventHotKeyID(signature: 0x43535754, id: 1)
        let result = RegisterEventHotKey(UInt32(kVK_ANSI_C), UInt32(controlKey | optionKey | cmdKey),
            identifier, GetApplicationEventTarget(), 0, &hotKey)
        if result != noErr { unregister() }
        return result == noErr
    }

    func unregister() {
        if let hotKey { UnregisterEventHotKey(hotKey) }
        if let handler { RemoveEventHandler(handler) }
        hotKey = nil
        handler = nil
    }
}
