import SwiftUI
import OpenAPIURLSession

struct CarrierInfoView: View {
    @State private var carriers: [Components.Schemas.Carrier] = []
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    let service: YandexRaspServiceProtocol
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Информация о перевозчике")
                .font(.title2)
                .bold()
            
            Text("🔍 Запрос выполнен для авиакомпании Аэрофлот (код IATA: SU)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if isLoading {
                ProgressView("Загружаем данные...")
            } else if let errorMessage {
                Text("Ошибка: \(errorMessage)")
                    .foregroundColor(.red)
            } else if carriers.isEmpty {
                Text("Нет данных для отображения")
            } else {
                List(carriers, id: \.code) { carrier in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(formattedCarrierTitle(carrier: carrier))
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                        if let url = carrier.url, let urlObj = URL(string: url) {
                            Link("🌐 \(url)", destination: urlObj)
                                .foregroundColor(.blue)
                        }
                        
                        if let address = carrier.address {
                            Text("🏢 Адрес:")
                                .bold()
                            Text(address)
                        }
                        
                        if let contacts = carrier.contacts, !contacts.isEmpty {
                            Text("📇 Контакты:")
                                .bold()
                            Text(contacts.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        if let logo = carrier.logo,
                           let logoURL = URL(string: logo.hasPrefix("http") ? logo : "https:" + logo) {
                            AsyncImage(url: logoURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 60)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                await loadCarrierInfo()
            }
        }
    }
    
    private func formattedCarrierTitle(carrier: Components.Schemas.Carrier) -> String {
        let icao = carrier.codes?.icao
        let iata = carrier.codes?.iata
        
        let codes = [icao, iata].compactMap { $0 }.joined(separator: " / ")
        let title = carrier.title ?? "Без названия"
        
        return codes.isEmpty ? title : "\(title) (\(codes))"
    }
    
    private func loadCarrierInfo() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await service.getCarrierInfo(
                code: "SU",
                system: "iata"
            )
            print("👉 Ответ от API: \(result)")

            if let carriers = result.carriers, !carriers.isEmpty {
                print("📦 carriers: \(carriers)")
                self.carriers = carriers
            } else {
                print("🚫 Нет данных о перевозчике")
                errorMessage = "Нет данных о перевозчике"
            }
        } catch {
            print("‼️ Ошибка загрузки: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
}
