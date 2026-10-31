import AppKit
import Observation

@MainActor
@Observable
final class CursorStore {
    static let shared = CursorStore()
    static let profileKey = "customCursorProfile.v1"

    var profile: CursorProfile {
        didSet {
            let safe = profile.sanitized
            if safe != profile { profile = safe }
            if let data = try? JSONEncoder().encode(safe) { defaults.set(data, forKey: Self.profileKey) }
            if isCustom {
                if CursorArtwork.validationMessage(for: safe) == nil {
                    renderer.update(profile: safe)
                } else {
                    selectDefault()
                }
            }
        }
    }
    private(set) var isCustom = false
    var errorMessage: String?
    var shortcutAvailable = true

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let visibility: any CursorVisibility
    @ObservationIgnored private let renderer: any CursorRendering

    init(defaults: UserDefaults = .standard,
         visibility: (any CursorVisibility)? = nil,
         renderer: (any CursorRendering)? = nil) {
        self.defaults = defaults
        self.visibility = visibility ?? NativeCursorVisibility()
        self.renderer = renderer ?? CursorOverlay()
        if let data = defaults.data(forKey: Self.profileKey),
           let saved = try? JSONDecoder().decode(CursorProfile.self, from: data) {
            profile = saved.sanitized
        } else {
            profile = CursorProfile()
        }
        // Always launch in default mode, including after a forced quit.
    }

    func selectCustom() {
        guard !isCustom else { return }
        errorMessage = nil
        if let message = CursorArtwork.validationMessage(for: profile) {
            errorMessage = message
            return
        }
        renderer.show(profile: profile)
        do {
            try visibility.hide()
            isCustom = true
        } catch {
            visibility.restore()
            renderer.dismiss()
            errorMessage = error.localizedDescription
        }
    }

    func selectDefault() {
        visibility.restore()
        renderer.dismiss()
        isCustom = false
        errorMessage = nil
    }

    func toggle() {
        if isCustom { selectDefault() } else { selectCustom() }
    }

    func resetProfile() { profile = CursorProfile() }
}
