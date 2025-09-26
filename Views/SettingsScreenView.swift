import SwiftUI
import OpenAPIURLSession

struct SettingsScreen: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showAgreement = false
    
    let service: YandexRaspServiceProtocol
    
    init(service: YandexRaspServiceProtocol) {
        self.service = service
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // контент
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("Тёмная тема")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.ypBlack)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Toggle("", isOn: $isDarkMode)
                            .labelsHidden()
                            .tint(.blueUniversal)
                    }
                    .frame(height: 56)
                    .padding(.horizontal, 16)
                    
                    Button {
                        showAgreement = true
                    } label: {
                        HStack(spacing: 0) {
                            Text("Пользовательское соглашение")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.ypBlack)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.ypBlack)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .frame(height: 56)
                    .padding(.horizontal, 16)
                }
                .padding(.top, 24)
                
                Spacer()
            }
            .padding(.bottom, 24)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemBackground))
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 6) {
                    Text("Приложение использует API «Яндекс.Расписания»")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.ypBlack)
                    
                    Text("Версия 1.0 (beta)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.ypBlack)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
            }
            .navigationDestination(isPresented: $showAgreement) {
                CopyrightView(service: service)
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }
}

#Preview {
    SettingsScreen(service: YandexRaspService(apikey: "c55262b4-2eb3-4048-bc82-05295a604f6c"))
}
