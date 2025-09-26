import SwiftUI

// MARK: - Stub source
private struct CarrierStub {
    let email: String?
    let phone: String?
    let logoName: String?

    static func forCarrier(name: String, fallbackLogo: String?) -> CarrierStub {
        switch name.lowercased() {
        case "ржд", "оао «ржд»", "оао ржд":
            return .init(email: "i.lozgkina@yandex.ru",
                         phone: "+7 (904) 329-27-71",
                         logoName: fallbackLogo ?? "LogoStub1")
        case "фгк":
            return .init(email: "info@fgk.ru",
                         phone: "+7 (495) 123-45-67",
                         logoName: fallbackLogo ?? "LogoStub2")
        case "урал логистика", "урал-логистика":
            return .init(email: "office@ural-logistics.ru",
                         phone: "+7 (343) 765-43-21",
                         logoName: fallbackLogo ?? "LogoStub3")
        default:
            return .init(email: nil, phone: nil, logoName: fallbackLogo)
        }
    }
}

// MARK: - View
struct CarrierInfoViewStub: View {
    let carrierName: String
    let carrierCode: String?
    let carrierLogo: String?

    private var stub: CarrierStub {
        CarrierStub.forCarrier(name: carrierName, fallbackLogo: carrierLogo)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                if let logo = stub.logoName {
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
                Text(formattedTitle(carrierName))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 6) {
                    Text("E-mail")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.ypBlack)
                    if let email = stub.email,
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
                    if let phone = stub.phone,
                       let url = URL(string: "tel:\(digits(from: phone))") {
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

    // MARK: - Helpers
    private func formattedTitle(_ raw: String) -> String {
        let lower = raw.lowercased()
        if lower == "ржд" || lower.contains("ржд") {
            return "ОАО «РЖД»"
        }
        return raw
    }

    private func digits(from phone: String) -> String {
        phone.filter { "0123456789+".contains($0) }
    }
}
#Preview {
    CarrierInfoViewStub(carrierName: "РЖД", carrierCode: "RZD", carrierLogo: "LogoStub1")
}
