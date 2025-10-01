import SwiftUI

struct CarrierInfoView: View {
    @StateObject private var viewModel: CarrierInfoViewModel
    
    init(api: YandexRaspAPIProtocol,
         carrierCode: String,
         system: String,
         fallbackCarrier: Components.Schemas.Carrier?) {
        _viewModel = StateObject(wrappedValue: CarrierInfoViewModel(
            api: api,
            carrierCode: carrierCode,
            system: system,
            fallbackCarrier: fallbackCarrier
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                if let logo = viewModel.carrier?.logo,
                   let url = URL(string: logo.hasPrefix("http") ? logo : "https:" + logo) {
                    HStack {
                        Spacer()
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(height: 104)
                        } placeholder: {
                            ProgressView()
                        }
                        Spacer()
                    }
                    .padding(.top, 16)
                }
                
                Text(viewModel.formattedTitle(viewModel.carrier?.title ?? "Без названия"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .padding(.top, 8)
                
                infoBlock(title: "E-mail", value: viewModel.extractedEmail(), linkPrefix: "mailto:")
                    .padding(.top, 8)
                
                infoBlock(title: "Телефон",
                          value: viewModel.extractedPhone(),
                          linkPrefix: "tel:",
                          applyDigits: true)
                
                if let urlString = viewModel.carrier?.url,
                   let url = URL(string: urlString) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Сайт")
                            .font(.system(size: 17))
                            .foregroundColor(.ypBlack)
                        
                        Link(urlString, destination: url)
                            .font(.system(size: 12))
                            .foregroundColor(.blueUniversal)
                    }
                }
                
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("Информация о перевозчике")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
        .task {
            await viewModel.loadCarrierInfo()
        }
        .navigationDestination(isPresented: $viewModel.showConnectionError) {
            ConnectionErrorView()
                .toolbar(.hidden, for: .tabBar)
        }
        .navigationDestination(isPresented: $viewModel.showServerError) {
            ServerErrorView()
                .toolbar(.hidden, for: .tabBar)
        }
    }
    
    @ViewBuilder
    private func infoBlock(title: String, value: String?, linkPrefix: String, applyDigits: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(.ypBlack)
            
            if let value = value, !value.isEmpty {
                let linkValue = applyDigits ? (viewModel.phoneLink(from: value) ?? value) : value
                if let url = URL(string: "\(linkPrefix)\(linkValue)") {
                    Link(value, destination: url)
                        .font(.system(size: 12))
                        .foregroundColor(.blueUniversal)
                } else {
                    Text(value)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            } else {
                Text("—")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 17))
            }
        }
    }
}
