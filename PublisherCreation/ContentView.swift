import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = StringIterationViewModel(text: "It's dangerous to go alone! Take this.")

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image("scene")
                    .resizable()
                    .scaledToFit()
                Text(self.viewModel.text)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .frame(maxWidth: 300)
                    .offset(y: -120)
            }
            .frame(maxWidth: proxy.size.width, maxHeight: proxy.size.height)
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.black)
    }
}
