import Foundation
import Testing
@testable import CursorSwitch

@MainActor
struct CursorStoreTests {
    private func makeStore() -> (CursorStore, MockVisibility, MockRenderer, UserDefaults) {
        let defaults = UserDefaults(suiteName: "CursorSwitchTests.\(UUID().uuidString)")!
        let visibility = MockVisibility()
        let renderer = MockRenderer()
        return (CursorStore(defaults: defaults, visibility: visibility, renderer: renderer), visibility, renderer, defaults)
    }

    @Test func repeatedSelectionDoesNotAccumulateHides() {
        let (store, visibility, renderer, _) = makeStore()
        store.selectCustom()
        store.selectCustom()
        #expect(visibility.hideCount == 1)
        #expect(renderer.showCount == 1)
        #expect(store.isCustom)
        store.selectDefault()
        #expect(!visibility.hidden)
        #expect(!renderer.visible)
        #expect(!store.isCustom)
    }

    @Test func failedHideRollsBackOverlayAndMode() {
        let (store, visibility, renderer, _) = makeStore()
        visibility.shouldFail = true
        store.selectCustom()
        #expect(!store.isCustom)
        #expect(!renderer.visible)
        #expect(!visibility.hidden)
        #expect(store.errorMessage != nil)
        visibility.shouldFail = false
        store.selectCustom()
        #expect(store.isCustom)
        #expect(store.errorMessage == nil)
    }

    @Test func settingsPersistButCustomModeDoesNot() {
        let (store, visibility, renderer, defaults) = makeStore()
        store.profile.shape = .diamond
        store.profile.size = 62
        store.profile.fill = CursorColor(red: 0.3, green: 0.6, blue: 0.8)
        store.selectCustom()
        let restored = CursorStore(defaults: defaults, visibility: visibility, renderer: renderer)
        #expect(restored.profile == store.profile)
        #expect(!restored.isCustom)
    }

    @Test func malformedPreferencesRecoverToDefaults() {
        let (_, visibility, renderer, defaults) = makeStore()
        defaults.set(Data("not json".utf8), forKey: CursorStore.profileKey)
        let restored = CursorStore(defaults: defaults, visibility: visibility, renderer: renderer)
        #expect(restored.profile == CursorProfile())
    }

    @Test func profileClampsUnsafeValues() {
        var profile = CursorProfile()
        profile.size = -200
        profile.fill = CursorColor(red: 5, green: -3, blue: .infinity)
        #expect(profile.sanitized.size == 18)
        #expect(profile.sanitized.fill == CursorColor(red: 1, green: 0, blue: 0))
        profile.size = .nan
        #expect(profile.sanitized.size == 36)
    }

    @Test func editsUpdateOnlyAnActiveOverlay() {
        let (store, _, renderer, _) = makeStore()
        store.profile.size = 40
        #expect(renderer.updateCount == 0)
        store.selectCustom()
        store.profile.size = 60
        #expect(renderer.updateCount == 1)
        #expect(renderer.lastProfile?.size == 60)
    }

    @Test func missingArtworkCannotHideNativeCursor() {
        let (store, visibility, renderer, _) = makeStore()
        store.profile.kind = .image
        store.selectCustom()
        #expect(!store.isCustom)
        #expect(!renderer.visible)
        #expect(visibility.hideCount == 0)
        #expect(store.errorMessage != nil)
    }

    @Test func invalidSymbolRestoresDefaultDuringEditing() {
        let (store, visibility, renderer, _) = makeStore()
        store.selectCustom()
        store.profile.kind = .symbol
        store.profile.symbolName = "this.symbol.does.not.exist"
        #expect(!store.isCustom)
        #expect(!visibility.hidden)
        #expect(!renderer.visible)
    }

    @Test func olderProfilesMigrateWithoutLosingStyle() throws {
        let data = Data(#"{"shape":"circle","size":50,"fill":{"red":1,"green":0,"blue":0},"outline":{"red":1,"green":1,"blue":1}}"#.utf8)
        let profile = try JSONDecoder().decode(CursorProfile.self, from: data)
        #expect(profile.kind == .shape)
        #expect(profile.shape == .circle)
        #expect(profile.size == 50)
        #expect(profile.hotspot == .automatic)
    }

    @Test func multiScalarEmojiIsKeptIntact() {
        var profile = CursorProfile()
        profile.emoji = "👩🏽‍💻🌟"
        #expect(profile.sanitized.emoji == "👩🏽‍💻")
    }
}

@MainActor
private final class MockVisibility: CursorVisibility {
    var hideCount = 0
    var hidden = false
    var shouldFail = false
    func hide() throws {
        hideCount += 1
        if shouldFail { throw CursorFailure.unsupported }
        hidden = true
    }
    func restore() { hidden = false }
}

@MainActor
private final class MockRenderer: CursorRendering {
    var showCount = 0
    var updateCount = 0
    var visible = false
    var lastProfile: CursorProfile?
    func show(profile: CursorProfile) { showCount += 1; visible = true; lastProfile = profile }
    func update(profile: CursorProfile) { updateCount += 1; lastProfile = profile }
    func dismiss() { visible = false }
}
