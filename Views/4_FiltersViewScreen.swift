import SwiftUI

// MARK: - FiltersView
struct FiltersView: View {
    @StateObject private var viewModel: FiltersViewModel
    let onBack: () -> Void
    let onApply: (Filters) -> Void
    
    init(onBack: @escaping () -> Void, onApply: @escaping (Filters) -> Void) {
        self.onBack = onBack
        self.onApply = onApply
        self._viewModel = StateObject(wrappedValue: FiltersViewModel())
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                Group {
                    SectionHeader("Время отправления")
                    CheckboxRow(title: "Утро 06:00 – 12:00", isOn: $viewModel.morning)
                    CheckboxRow(title: "День 12:00 – 18:00", isOn: $viewModel.dayTime)
                    CheckboxRow(title: "Вечер 18:00 – 00:00", isOn: $viewModel.evening)
                    CheckboxRow(title: "Ночь 00:00 – 06:00", isOn: $viewModel.night)
                }
                
                Group {
                    SectionHeader("Показывать варианты с пересадками")
                    RadioRow(title: "Да", isSelected: viewModel.transfers == .yes) {
                        viewModel.setTransfers(.yes)
                    }
                    RadioRow(title: "Нет", isSelected: viewModel.transfers == .no) {
                        viewModel.setTransfers(.no)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .foregroundColor(.ypBlack)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.canApply {
                Button {
                    let filters = Filters(
                        morning: viewModel.morning,
                        dayTime: viewModel.dayTime,
                        evening: viewModel.evening,
                        night: viewModel.night,
                        transfers: viewModel.transfers == .yes ? true : (viewModel.transfers == .no ? false : nil)
                    )
                    onApply(filters)
                    onBack()
                } label: {
                    Text("Применить")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.whiteUniversal)
                        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(Color.blueUniversal)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.2), value: viewModel.canApply)
            }
        }
    }
}

// MARK: - Typography
private enum TSFont {
    static let section = Font.system(size: 24, weight: .bold)
    static let row     = Font.system(size: 17, weight: .regular)
}

// MARK: - Subviews
private struct SectionHeader: View {
    let text: String
    init(_ text: String) { self.text = text }
    
    var body: some View {
        Text(text)
            .font(TSFont.section)
            .foregroundColor(.ypBlack)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            .padding(.bottom, 16)
    }
}

private struct CheckboxRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(TSFont.row)
                .foregroundColor(.ypBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Checkbox(isOn: isOn)
        }
        .frame(height: 60)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) { isOn.toggle() }
        }
    }
}

private struct Checkbox: View {
    var isOn: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(.primary, lineWidth: 2)
                .frame(width: 24, height: 24)
            
            if isOn {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.ypBlack)
            }
        }
        .accessibilityLabel(isOn ? "Выбрано" : "Не выбрано")
    }
}

private struct RadioRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(TSFont.row)
                .foregroundColor(.ypBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Radio(isSelected: isSelected)
        }
        .frame(height: 60)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) { action() }
        }
    }
}

private struct Radio: View {
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.primary, lineWidth: 2)
                .foregroundColor(.ypBlack)
                .frame(width: 24, height: 24)
            
            if isSelected {
                Circle()
                    .fill(.ypBlack)
                    .frame(width: 12, height: 12)
            }
        }
        .accessibilityLabel(isSelected ? "Выбрано" : "Не выбрано")
    }
}
