import SwiftUI

// MARK: - Struct
struct Filters {
    var morning: Bool
    var dayTime: Bool
    var evening: Bool
    var night: Bool
    var transfers: Bool?
}

// MARK: - Results
struct ResultsView: View {
    let fromCode: String
    let toCode: String
    let fromTitle: String
    let toTitle: String
    @StateObject private var viewModel: ResultsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(fromCode: String, toCode: String, fromTitle: String, toTitle: String, api: YandexRaspAPIProtocol) {
        self.fromCode = fromCode
        self.toCode = toCode
        self.fromTitle = fromTitle
        self.toTitle = toTitle
        self._viewModel = StateObject(wrappedValue: ResultsViewModel(api: api, fromCode: fromCode, toCode: toCode))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Text("\(fromTitle) → \(toTitle)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.ypBlack)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.ypWhite)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Загружаем рейсы…")
                    Spacer()
                } else if viewModel.items.isEmpty {
                    Spacer()
                    ContentPlaceholder(title: "Вариантов нет")
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.items) { item in
                                SegmentCard(item: item)
                                    .contentShape(Rectangle())
                                    .onTapGesture { viewModel.selectedItem = item }
                            }
                        }
                        .padding([.horizontal, .vertical], 16)
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .foregroundColor(.ypBlack)
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.showConnectionError) {
            ConnectionErrorView()
                .toolbar(.hidden, for: .tabBar)
        }
        .navigationDestination(isPresented: $viewModel.showServerError) {
            ServerErrorView()
                .toolbar(.hidden, for: .tabBar)
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.items.isEmpty {
                VStack(spacing: 0) {
                    Button { viewModel.showFilters = true } label: {
                        HStack(spacing: 4) {
                            Text("Уточнить время")
                                .font(.system(size: 17, weight: .bold))
                            if viewModel.filtersApplied {
                                Circle()
                                    .fill(Color.redUniversal)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.white)
                    .background(.blueUniversal)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationDestination(item: $viewModel.selectedItem) { item in
            if let (code, system) = item.carrierPreferredCodeAndSystem {
                CarrierInfoView(
                    api: viewModel.api,
                    carrierCode: code,
                    system: system,
                    fallbackCarrier: item.carrierCodes
                )
                .toolbar(.hidden, for: .tabBar)
            } else {
                Text("Нет данных о перевозчике")
            }
        }
        .navigationDestination(isPresented: $viewModel.showFilters) {
            FiltersView(
                onBack: { viewModel.showFilters = false },
                onApply: { filters in
                    viewModel.applyFilters(filters)
                    viewModel.showFilters = false
                }
            )
        }
        .onAppear {
            viewModel.loadIfNeeded()
        }
    }
}

// MARK: - Card
private struct SegmentCard: View {
    let item: SegmentItem
    
    private var transportIcon: String {
        switch item.transportType {
        case "plane": return "airplane"
        case "train": return "train.side.front.car"
        case "suburban": return "tram.fill"
        case "bus": return "bus"
        case "water": return "ferry"
        case "helicopter": return "helicopter"
        default: return "questionmark.circle"
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(Color.clear)
                    if let logo = item.carrierLogo, let url = URL(string: logo) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 38, height: 38)
                        } placeholder: {
                            ProgressView().frame(width: 38, height: 38)
                        }
                    } else {
                        Image(systemName: transportIcon)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.secondary)
                            .frame(width: 38, height: 38)
                    }
                }
                .frame(width: 38, height: 38)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(item.carrierName)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.blackUniversal)
                    if let transfer = item.transferText {
                        Text(transfer)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.redUniversal)
                    }
                }
                
                Spacer()
                Text(item.departureDateShort)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.blackUniversal)
            }
            
            HStack {
                Text(item.departureTime)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.blackUniversal)
                
                ZStack {
                    Capsule()
                        .fill(Color.grayUniversal)
                        .frame(height: 1)
                    
                    Text(item.durationText)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.blackUniversal)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(.simpleGray)
                }
                
                Text(item.arrivalTime)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.blackUniversal)
            }
            .frame(height: 40)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.simpleGray))
                .frame(height: 104)
        )
    }
}

// MARK: - Segment mapping

fileprivate let shortDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ru_RU")
    f.setLocalizedDateFormatFromTemplate("d MMMM")
    return f
}()

fileprivate let timeFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    f.timeZone = TimeZone.current
    f.locale = Locale(identifier: "ru_RU")
    return f
}()

// MARK: - SegmentItem Extension
extension SegmentItem {
    var carrierPreferredCodeAndSystem: (code: String, system: String)? {
        if let iata = carrierCodes.codes?.iata { return (iata, "iata") }
        if let icao = carrierCodes.codes?.icao { return (icao, "icao") }
        if let sirena = carrierCodes.codes?.sirena { return (sirena, "sirena") }
        if let code = carrierCodes.code { return (String(describing: code), "internal") }
        return nil
    }
    
    init?(from segment: Components.Schemas.Segment) {
        guard
            let thread = segment.thread,
            let dep = segment.departure,
            let arr = segment.arrival
        else { return nil }
        
        let carrier = thread.carrier ?? Components.Schemas.Carrier(
            code: nil, contacts: nil, url: nil, title: "Железная дорога",
            phone: nil, address: nil, logo: nil, email: nil, codes: nil
        )
        
        self.init(
            id: UUID().uuidString,
            carrierName: carrier.title ?? "Без названия",
            carrierCode: carrier.codes?.iata ?? carrier.codes?.icao ?? carrier.codes?.sirena
            ?? (carrier.code.map { String(describing: $0) }) ?? "",
            carrierLogo: carrier.logo,
            departureDateShort: shortDateFormatter.string(from: dep),
            departureTime: timeFormatter.string(from: dep),
            arrivalTime: timeFormatter.string(from: arr),
            durationText: SegmentItem.formatDuration(segment.duration ?? 0),
            transferText: (segment.has_transfers == true) ? "С пересадкой" : nil,
            hasTransfers: segment.has_transfers,
            carrierCodes: carrier,
            transportType: thread.transport_type
        )
    }
    
    private static func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours) ч \(mins) мин"
        } else {
            return "\(mins) мин"
        }
    }
}
