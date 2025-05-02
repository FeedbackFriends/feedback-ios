import Helpers
import Foundation

extension FeedbackSession {
    static var mock: Self {
        .init(
            title: "Mock Session",
            agenda: "Testing agenda",
            questions: [],
            ownerInfo: .init(name: "User", email: "email", phoneNumber: "000"),
            pinCode: .init(value: "1234"),
            date: .init(timeIntervalSince1970: 0)
        )
    }
}
