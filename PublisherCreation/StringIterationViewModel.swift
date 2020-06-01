import Combine

class StringIterationViewModel: ObservableObject {
    @Published var text: String
    private let publisher: StringIterationPublisher
    private var cancellables = Set<AnyCancellable>()

    init(text: String) {
        self.text = ""
        publisher = StringIterationPublisher(text: text, delay: 0.03...0.09)
        publisher.map { $0.uppercased() }.assign(to: \.text, on: self).store(in: &cancellables)
    }
}
