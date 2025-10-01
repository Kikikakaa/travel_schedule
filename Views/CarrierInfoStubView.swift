import SwiftUI

struct CarrierInfoViewStub: View {
    @StateObject private var viewModel: CarrierInfoStubViewModel
    
    init(carrierName: String, carrierCode: String?, carrierLogo: String?) {
        self._viewModel = StateObject(wrappedValue: CarrierInfoStubViewModel(carrierName: carrierName, carrierCode: carrierCode, carrierLogo: carrierLogo))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let logo = viewModel.stub.logoName {
                    HStack {
                        Spacer()
                        Image(logo)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 104)
                        Spacer()
                    }
                    .padding(.top, 16)
                } else {
                    Spacer(minLength: 8)
                }
                
                Text(viewModel.formattedTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("E-mail")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.ypBlack)
                    if let email = viewModel.stub.email,
                       let url = URL(string: "mailto:\(email)") {
                        Link(email, destination: url)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.blueUniversal)
                    } else {
                        Text("—")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 17, weight: .regular))
                    }
                }
                .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Телефон")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.ypBlack)
                    if let phone = viewModel.stub.phone,
                       let url = URL(string: "tel:\(viewModel.digits(from: phone))") {
                        Link(phone, destination: url)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.blueUniversal)
                    } else {
                        Text("—")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 17, weight: .regular))
                    }
                }
                
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("Информация о перевозчике")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }
}

#Preview {
    CarrierInfoViewStub(carrierName: "РЖД", carrierCode: "RZD", carrierLogo: "LogoStub1")
}
