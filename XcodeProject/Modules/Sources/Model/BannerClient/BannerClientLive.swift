//import ComposableArchitecture
//import Foundation
//
//public enum Priority {
//    case high, medium, low
//}
//
//public protocol BannerMessage: Equatable, Sendable {
//    var message: String { get }
//    func onTap()
//}
//
//actor BannerQueue {
//    
//    private let stream: AsyncStream<any BannerMessage>
//    private let continuation: AsyncStream<any BannerMessage>.Continuation
//    
//    init() {
//        var cont: AsyncStream<any BannerMessage>.Continuation! = nil
//        let str = AsyncStream<any BannerMessage> { c in
//            cont = c
//        }
//        self.stream = str
//        self.continuation = cont
//    }
//    
//    // 2️⃣ Publicly expose the stream
//    nonisolated func messagesStream() -> AsyncStream<any BannerMessage> {
//        stream
//    }
//    
//    // 3️⃣ Properly yield into the continuation
//    func addMessage(_ message: any BannerMessage) async {
//        // keep your 2s delay if you need it
//        try? await Task.sleep(for: .seconds(2))
//        continuation.yield(message)
//    }
//}
//
//@DependencyClient
//public struct BannerQueueClient: Sendable {
//    public var addToQueue: @Sendable (_ message: any BannerMessage) -> Void
//    public var showBanner: @Sendable () async -> AsyncStream<any BannerMessage> = { .never }
//    
//    public static func live() -> BannerQueueClient {
//        let queue = BannerQueue()
//        return .init(
//            addToQueue: { message in
//                // fire-and-forget onto the actor
//                Task { await queue.addMessage(message) }
//            },
//            showBanner: {
//                queue.messagesStream()
//            }
//        )
//    }
//}
