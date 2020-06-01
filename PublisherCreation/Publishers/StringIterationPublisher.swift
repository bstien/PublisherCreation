import Foundation
import Combine

struct StringIterationPublisher: Publisher {
    typealias Output = String
    typealias Failure = Never

    private let delayRange: ClosedRange<Double>
    private let text: String

    init(text: String, delay: ClosedRange<Double>) {
        self.text = text
        self.delayRange = delay
    }

    init(text: String, delay: Double = 0.1) {
        self.text = text
        self.delayRange = delay...delay
    }

    func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = StringIterationSubscription(text: text, delayRange: delayRange, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

private class StringIterationSubscription<S: Subscriber>: Subscription where S.Input == String, S.Failure == Never {
    private var subscriber: S?
    private let text: String
    private let delayRange: ClosedRange<Double>
    private var cancellables = Set<AnyCancellable>()

    init(text: String, delayRange: ClosedRange<Double>, subscriber: S) {
        self.text = text
        self.delayRange = delayRange
        self.subscriber = subscriber
        startPublishing()
    }

    func request(_ demand: Subscribers.Demand) {
    }

    func cancel() {
        subscriber = nil
    }

    private func startPublishing() {
        guard let subscriber = subscriber else { return }
        let letterPublisher = text.map { String($0) }.publisher
        let delayPublisher = RandomDelayPublisher(delay: delayRange)

        Publishers.Zip(letterPublisher, delayPublisher)
            .scan("", { $0 + $1.0 })
            .receive(on: RunLoop.main)
            .sink(receiveValue: { subscriber.receive($0)})
            .store(in: &cancellables)
    }
}
