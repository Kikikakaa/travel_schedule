import SwiftUI

struct StationListView: View {
    let city: City
    let cityTitle: String
    let cityCode: String
    @ObservedObject var stationsVM: AllStationsViewModel
    @Binding var selection: StationSelection
    
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""
    
    private var allStations: [StationItem] {
        let settlements = stationsVM.countries
            .flatMap { $0.regions ?? [] }
            .flatMap { $0.settlements ?? [] }
            .filter { $0.codes?.yandex_code == city.id }
        
        let stations = settlements
            .flatMap { $0.stations ?? [] }
            .compactMap { st -> StationItem? in
                guard let code = st.codes?.yandex_code,
                      let title = st.title else { return nil }
                return StationItem(
                    id: code,
                    title: title,
                    transportType: st.transport_type,
                    stationType: st.station_type
                )
            }
        
        return stations.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }
    
    private var filtered: [StationItem] {
        guard !query.isEmpty else { return allStations }
        return allStations.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Введите запрос", text: $query)
                    .font(.system(size: 17, weight: .regular))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
                
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
            
            List {
                ForEach(filtered) { st in
                    Button {
                        selection = StationSelection(
                            displayText: "\(cityTitle) (\(st.title))",
                            code: st.id
                        )
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(st.title)
                                    .foregroundColor(.ypBlack)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 17))
                                .foregroundColor(.ypBlack)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .overlay {
                if allStations.isEmpty {
                    emptyView("Станции не найдены")
                } else if filtered.isEmpty {
                    emptyView("Не найдено")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.ypBlack)
                        .frame(width: 44, height: 44)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Выбор станции")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.ypBlack)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Color(.systemBackground))
    }
    
    // MARK: - STUB
    @ViewBuilder
    private func emptyView(_ text: String) -> some View {
        if #available(iOS 17, *) {
            ContentUnavailableView {
                Text(text)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.ypBlack)
            }
        } else {
            VStack {
                Text(text)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.ypBlack)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
