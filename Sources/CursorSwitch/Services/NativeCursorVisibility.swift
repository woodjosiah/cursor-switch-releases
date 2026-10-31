import AppKit
import Darwin

@MainActor
protocol CursorVisibility: AnyObject {
    func hide() throws
    func restore()
}

/// The sole private-API boundary. Symbols are optional and resolved at runtime.
/// No system preference, cursor asset, or global cursor scale is modified.
@MainActor
final class NativeCursorVisibility: CursorVisibility {
    private typealias Connection = @convention(c) () -> Int32
    private typealias SetProperty = @convention(c) (Int32, Int32, CFString, CFTypeRef) -> Int32
    private typealias IsVisible = @convention(c) () -> Int32

    private var hideCount = 0
    private var watchdog: Timer?
    private var isVisible: IsVisible?
    private var handle: UnsafeMutableRawPointer?
    private var connection: Connection?
    private var setProperty: SetProperty?

    init() {
        handle = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_LAZY)
        guard let handle else { return }
        if let symbol = dlsym(handle, "SLSMainConnectionID") ?? dlsym(handle, "CGSMainConnectionID") {
            connection = unsafeBitCast(symbol, to: Connection.self)
        }
        if let symbol = dlsym(handle, "SLSSetConnectionProperty") ?? dlsym(handle, "CGSSetConnectionProperty") {
            setProperty = unsafeBitCast(symbol, to: SetProperty.self)
        }
        if let symbol = dlsym(handle, "SLCursorIsVisible") {
            isVisible = unsafeBitCast(symbol, to: IsVisible.self)
        }
    }

    func hide() throws {
        guard hideCount == 0 else { return }
        guard let connection, let setProperty else { throw CursorFailure.unsupported }
        let identifier = connection()
        guard setProperty(identifier, identifier, "SetsCursorInBackground" as CFString, kCFBooleanTrue) == 0 else {
            throw CursorFailure.unsupported
        }
        guard CGDisplayHideCursor(CGMainDisplayID()) == .success else {
            _ = setProperty(identifier, identifier, "SetsCursorInBackground" as CFString, kCFBooleanFalse)
            throw CursorFailure.cannotHide
        }
        hideCount = 1
        // Apps and Spaces can make the native cursor visible again. Only acquire
        // another hide when that actually happens, and release every owned hide.
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.maintainVisibility() }
        }
        timer.tolerance = 0.02
        RunLoop.main.add(timer, forMode: .common)
        watchdog = timer
    }

    func restore() {
        watchdog?.invalidate()
        watchdog = nil
        guard hideCount > 0 else { return }
        while hideCount > 0 {
            CGDisplayShowCursor(CGMainDisplayID())
            hideCount -= 1
        }
        if let connection, let setProperty {
            let identifier = connection()
            _ = setProperty(identifier, identifier, "SetsCursorInBackground" as CFString, kCFBooleanFalse)
        }
    }

    private func maintainVisibility() {
        guard hideCount > 0, let isVisible, isVisible() != 0 else { return }
        if CGDisplayHideCursor(CGMainDisplayID()) == .success { hideCount += 1 }
    }
}

enum CursorFailure: LocalizedError {
    case unsupported, cannotHide

    var errorDescription: String? {
        switch self {
        case .unsupported: "Custom cursors aren’t supported on this version of macOS. Your default cursor is still active."
        case .cannotHide: "macOS couldn’t switch the cursor. Your default cursor is still active."
        }
    }
}
