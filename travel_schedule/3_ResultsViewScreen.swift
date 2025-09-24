import SwiftUI
// MARK: - Results
struct ResultsView: View {
    let from: String
    let to: String
    @Environment(\.dismiss) private var dismiss

    @State private var showFilters = false
    @State private var items: [SegmentItem] = SegmentItem.mock
    @State private var isLoading = false
    @State private var error: String?
    @State private var filtersApplied = false
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Загружаем рейсы…")
            } else if let error {
                VStack(spacing: 12) {
                    Text("Не удалось загрузить расписание").font(.headline)
                    Text(error).foregroundStyle(.secondary)
                    Button("Повторить") { load() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if items.isEmpty {
                ContentPlaceholder(
                    systemImage: "train.side.front.car",
                    title: "Пока пусто",
                    subtitle: "Попробуйте другую дату или фильтры."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(items) { item in
                            SegmentCard(item: item)
                                .onTapGesture {
                                    // TODO: переход на детали рейса
                                }
                        }
                    }
                    .padding([.horizontal, .vertical], 16)
                }
            }
        }
        .navigationTitle(Text(""))
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
        .safeAreaInset(edge: .top, alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(from) → \(to)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
            }
            .padding(.top, 16)
            .padding(.bottom, 0)
        }
        .safeAreaInset(edge: .bottom) {
            if !items.isEmpty {
                VStack(spacing: 0) {
                    Button {
                        showFilters = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("Уточнить время")
                                .font(.system(size: 17, weight: .bold))
                            if filtersApplied {
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
        .navigationDestination(isPresented: $showFilters) {
            FiltersView(
                onBack: { showFilters = false },
                onApply: { filtersApplied = true; showFilters = false } // <-- NEW
            )
        }
        .onAppear { load() }
    }

    private func load() {
        isLoading = false
        error = nil
    }
}
// MARK: - Card
private struct SegmentCard: View {
    let item: SegmentItem

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(Color.clear)
                    if let name = item.carrierLogo, !name.isEmpty {
                        Image(name).resizable().scaledToFill()
                    } else {
                        Image(systemName: "train.side.front.car")
                            .scaledToFill()
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 38, height: 38)
                //.background(Color.white)

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
                //.background(Color.yellow)

                Spacer()
                Text(item.departureDateShort)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.blackUniversal)

            }
            //.background(Color.blue)

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
                .padding(.horizontal, 0)
                //.background(Color.red)

                Text(item.arrivalTime)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.blackUniversal)
            }
            //.background(Color.green)
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
#Preview {
    ResultsView(from: "Санкт-Петербург", to: "Москва (Ленинградский вокзал)")
}
