import SwiftUI

struct CopyrightView: View {
    @StateObject private var viewModel = CopyrightViewModel(api: APIProvider.makeDefault())

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Авторские права")
                .font(.title)
                .bold()

            Text(viewModel.copyright)
                .font(.body)

            if let url = URL(string: viewModel.url) {
                Link("Подробнее", destination: url)
                    .foregroundColor(.blue)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.load()
        }
    }
}
