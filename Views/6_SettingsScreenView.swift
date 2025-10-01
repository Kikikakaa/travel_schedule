import SwiftUI

struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsScreenViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("Тёмная тема")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.ypBlack)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Toggle("", isOn: $viewModel.isDarkMode)
                            .labelsHidden()
                            .tint(.blueUniversal)
                    }
                    .frame(height: 56)
                    .padding(.horizontal, 16)
                    
                    Button {
                        viewModel.openAgreement()
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
            .navigationDestination(isPresented: $viewModel.showAgreement) {
                CopyrightView()
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }
}

#Preview {
    SettingsScreen()
}
