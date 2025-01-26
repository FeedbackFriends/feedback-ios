//  File.swift
//
//
//  Created by Nicolai Dam on 26/09/2021.
//

import Combine
import Foundation
import Network

#warning("Todo: make async await style")
public struct NetworkMonitor {
    public var publisher: () -> AnyPublisher<NWPath, Never> = { Publishers.NetworkPublisher().eraseToAnyPublisher() }
}

extension Publishers {
    class NetworkSubscription<S: Subscriber>: Subscription where S.Failure == Never, S.Input == NWPath {

        lazy var pathMonitor = NWPathMonitor()

        func request(_ demand: Subscribers.Demand) {

        }

        func cancel() {
            pathMonitor.cancel()
            subscriber = nil
        }

        private var subscriber: S?

        init(subscriber: S, queue: DispatchQueue) {
            self.subscriber = subscriber
            self.pathMonitor.pathUpdateHandler = {
                _ = subscriber.receive($0)
            }

            pathMonitor.start(queue: queue)

        }
    }

    public struct NetworkPublisher: Publisher {

        public typealias Output = NWPath
        public typealias Failure = Never

        let queue: DispatchQueue

        public init(queue: DispatchQueue = .main) {
            self.queue = queue
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let sub = NetworkSubscription(subscriber: subscriber, queue: queue)
            subscriber.receive(subscription: sub)
        }
    }
}
