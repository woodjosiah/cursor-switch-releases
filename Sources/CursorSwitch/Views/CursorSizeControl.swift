import SwiftUI
import OSLog

struct CursorSizeControl: View {
    @Binding var size: Double
    @State private var lastHapticTime: TimeInterval = 0
    private let logger = Logger(subsystem: "com.josiah.cursorswitch", category: "Haptics")

    var body: some View {
        LabeledContent("Size") {
            Slider(value: sliderValue, in: CursorProfile.sizeRange)
                .accessibilityLabel("Cursor size")
                .accessibilityValue("\(Int(size)) points")
            Text("\(Int(size)) pt").monospacedDigit().frame(width: 46, alignment: .trailing)
        }
    }

    // Only writes originating from the slider request feedback. Rounding keeps
    // one-point precision without asking SwiftUI to draw a tick for every point.
    private var sliderValue: Binding<Double> {
        Binding(get: { size }, set: { proposed in
            guard proposed.isFinite else { return }
            let new = min(max(proposed.rounded(), CursorProfile.sizeRange.lowerBound), CursorProfile.sizeRange.upperBound)
            let old = size
            guard old != new else { return }
            size = new
            guard Self.crossesFeedbackMark(from: old, to: new) else { return }
            let now = ProcessInfo.processInfo.systemUptime
            guard now - lastHapticTime >= 0.05 else { return }
            lastHapticTime = now
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
            logger.debug("Requested cursor-size haptic feedback")
        })
    }

    nonisolated static func crossesFeedbackMark(from old: Double, to new: Double) -> Bool {
        guard old.isFinite, new.isFinite, old != new else { return false }
        if new == CursorProfile.sizeRange.lowerBound || new == CursorProfile.sizeRange.upperBound { return true }
        return floor(old / 10) != floor(new / 10)
    }
}
