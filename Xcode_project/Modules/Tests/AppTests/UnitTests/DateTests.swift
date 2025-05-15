import Testing
import Utility
import Foundation

@MainActor
class DateTests {
    
    @Test
    func roundedUpcoming5MinRoundsCorrectly() {
        let now = Date()
        let roundedDate = now.roundedUpcoming5Min()
        let expectedTime = Date(
            timeIntervalSinceReferenceDate: (now.timeIntervalSinceReferenceDate / 300.0).rounded(.up) * 300.0
        )
        #expect(roundedDate == expectedTime)
    }
    
    @Test
    func isTodayReturnsTrueForToday() {
        let date = Date()
        #expect(date.isToday == true)
    }
    
    @Test
    func isAfterTodayReturnsTrueForDateAfterToday() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        #expect(tomorrow.isAfterToday == true)
    }
    
    @Test
    func isBeforeTodayReturnsTrueForDateBeforeToday() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        #expect(yesterday.isBeforeToday == true)
    }
    
    @Test
    func timeAgoReturnsCorrectString() {
        let date = Date(timeIntervalSinceNow: -3600) // 1 hour ago
        #expect(date.timeAgo(Locale(identifier: "en_US")) == "one hour ago")
    }
}
