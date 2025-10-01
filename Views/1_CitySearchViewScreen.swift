import SwiftUI

struct CitySearchView: View {
    let title: String
    
    @Binding var selection: StationSelection
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCity: City?
    @StateObject private var vm: CitySearchViewModel
    
    init(
        title: String,
        selection: Binding<StationSelection>,
        stationsVM: AllStationsViewModel,
        locationService: LocationServiceProtocol,
        api: YandexRaspAPI
    ) {
        self.title = title
        self._selection = selection
        _vm = StateObject(wrappedValue: CitySearchViewModel(
            stationsVM: stationsVM,
            locationService: locationService
        ))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Введите запрос", text: $vm.query)
                    .font(.system(size: 17, weight: .regular))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
            
            if vm.isLoading {
                ProgressView("Загрузка городов…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(vm.filtered) { city in
                    Button {
                        selectedCity = city
                    } label: {
                        HStack {
                            Text(city.title).foregroundColor(.ypBlack)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 17))
                                .foregroundStyle(.ypBlack)
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .overlay {
                    if vm.filtered.isEmpty {
                        if #available(iOS 17, *) {
                            ContentUnavailableView {
                                Text("Город не найден")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.ypBlack)
                            }
                        } else {
                            VStack {
                                Text("Город не найден")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.ypBlack)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
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
                Text("Выбор города")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.ypBlack)
            }
        }
        .onAppear { vm.loadCities() }
        .navigationDestination(item: $selectedCity) { city in
            StationListView(
                city: city,
                cityTitle: city.title,
                cityCode: city.id,
                stationsVM: vm.stationsVM,
                selection: $selection
            )
        }
        .onChange(of: selection.displayText) { _, newValue in
            if !newValue.isEmpty { dismiss() }
        }
    }
}
