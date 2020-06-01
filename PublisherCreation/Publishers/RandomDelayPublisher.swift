import Foundation
import Combine

struct RandomDelayPublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never

    private let delay: ClosedRange<Double>

    init(delay: ClosedRange<Double>) {
        self.delay = delay
    }

    init(delay: Double) {
        self.delay = (delay...delay)
    }

    func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = RandomDelaySubscription(delay: delay, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

private class RandomDelaySubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
    private var subscriber: S?
    private let delay: ClosedRange<Double>

    init(delay: ClosedRange<Double>, subscriber: S) {
        self.delay = delay
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

        subscriber.receive()

        dispatchAfter(delayRange: delay) { [weak self] in
            guard let subscriber = self?.subscriber else { return }
            subscriber.receive()
        }
    }

    private func dispatchAfter(delayRange: ClosedRange<Double>, block: @escaping () -> Void) {
        let randomDelay = Double.random(in: delayRange)
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) { [weak self] in
            guard let self = self else { return }
            block()
            self.dispatchAfter(delayRange: delayRange, block: block)
        }
    }
}
