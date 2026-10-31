import Foundation
import Testing
@testable import CursorSwitch

struct CursorControlTests {
    @Test func sizeSupports120AndClampsBeyondIt() {
        var profile = CursorProfile()
        profile.size = 120
        #expect(profile.sanitized.size == 120)
        profile.size = 150
        #expect(profile.sanitized.size == 120)
    }

    @Test func hapticMarksAreSpacedAndIncludeEndpoints() {
        #expect(!CursorSizeControl.crossesFeedbackMark(from: 18, to: 19))
        #expect(CursorSizeControl.crossesFeedbackMark(from: 19, to: 20))
        #expect(!CursorSizeControl.crossesFeedbackMark(from: 31, to: 32))
        #expect(CursorSizeControl.crossesFeedbackMark(from: 119, to: 120))
        #expect(CursorSizeControl.crossesFeedbackMark(from: 19, to: 18))
        #expect(!CursorSizeControl.crossesFeedbackMark(from: 120, to: 120))
    }
}
