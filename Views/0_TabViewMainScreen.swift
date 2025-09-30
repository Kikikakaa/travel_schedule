import SwiftUI
import OpenAPIURLSession

// MARK: - Root

struct ContentView: View {
    enum selectedTab { case schedule, settings }
    @State private var tab: selectedTab = .schedule
    
    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { ScheduleScreen() }
                .tabItem { Image("Schedule").renderingMode(.template) }
                .tag(selectedTab.schedule)
            
            NavigationStack { SettingsScreen() }
                .tabItem { Image("Settings").renderingMode(.template) }
                .tag(selectedTab.settings)
        }
        .tint(.ypBlack)
    }
}

// MARK: - Schedule

struct ScheduleScreen: View {
    @StateObject private var vm: ScheduleViewModel
    @State private var error: AppError?

    init() {
        let url = URL(string: "https://api.rasp.yandex.net")
        if url == nil {
            assertionFailure("Invalid base URL")
        }

        let api = YandexRaspAPI(
            client: Client(
                serverURL: url ?? URL(string: "https://example.com")!,
                transport: URLSessionTransport()
            ),
            apikey: API.key
        )
        _vm = StateObject(wrappedValue: ScheduleViewModel(api: api))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(vm.stories.indices, id: \.self) { i in
                            let s = vm.stories[i]
                            StoryCard(story: s, isViewed: vm.viewedStories.contains(i))
                                .onTapGesture { vm.openStory(at: i) }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 24)

                SearchPanel(
                    from: $vm.from,
                    to: $vm.to,
                    onSwap: vm.swapStations,
                    onFromTap: { vm.showFromSearch = true },
                    onToTap: { vm.showToSearch = true }
                )
                .padding(.top, 20)
                .padding([.horizontal, .bottom], 16)

                if vm.canSearch {
                    NavigationLink {
                        ResultsView(
                            fromCode: vm.from.code,
                            toCode: vm.to.code,
                            fromTitle: vm.from.displayText,
                            toTitle: vm.to.displayText,
                            api: vm.api
                        )
                        .toolbar(.hidden, for: .tabBar)
                    } label: {
                        Text("Найти")
                            .font(.system(size: 17, weight: .bold))
                            .frame(width: 150, height: 60)
                            .background(.blueUniversal)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
        }

        .navigationDestination(isPresented: $vm.showFromSearch) {
            CitySearchView(
                title: "Откуда",
                selection: $vm.from,
                stationsVM: vm.stationsVM,
                locationService: vm.locationService,
                api: vm.api as! YandexRaspAPI
            )
            .toolbar(.hidden, for: .tabBar)
        }
        .navigationDestination(isPresented: $vm.showToSearch) {
            CitySearchView(
                title: "Куда",
                selection: $vm.to,
                stationsVM: vm.stationsVM,
                locationService: vm.locationService,
                api: vm.api as! YandexRaspAPI
            )
            .toolbar(.hidden, for: .tabBar)
        }
        .fullScreenCover(isPresented: $vm.showStory) {
            if let idx = vm.currentStoryIndex {
                MainStoryView(
                    stories: vm.stories,
                    startIndex: idx,
                    onClose: vm.closeStory
                )
            }
        }
        .navigationDestination(item: $error) { err in
            switch err {
            case .connection:
                ConnectionErrorView()
                    .toolbar(.hidden, for: .tabBar)
            case .server:
                ServerErrorView()
                    .toolbar(.hidden, for: .tabBar)
            }
        }
        .onAppear {
            Task {
                do {
                    try await vm.loadInitialData()
                } catch {
                    self.error = mapError(error)
                }
            }
        }
    }

    // MARK: - Helpers
    private func mapError(_ error: Error) -> AppError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                 .timedOut,
                 .cannotFindHost,
                 .cannotConnectToHost:
                return .connection
            default:
                return .server
            }
        }
        return .server
    }
}

// MARK: - Story card

struct StoryCard: View {
    let story: Stories
    let isViewed: Bool
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let img = story.backgroundImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 92, height: 140)
                    .clipped()
            } else {
                story.backgroundColor
            }
            
            if isViewed {
                Color.white.opacity(0.5)
            }
            
            Text(story.description)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
                .shadow(radius: 2)
        }
        .frame(width: 92, height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isViewed ? Color.clear  : Color.blueUniversal, lineWidth: 3)
        )
    }
}

// MARK: - Search panel
struct SearchPanel: View {
    @Binding var from: StationSelection
    @Binding var to: StationSelection
    let onSwap: () -> Void
    let onFromTap: () -> Void
    let onToTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundColor(.blueUniversal)
                .frame(height: 128)
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.whiteUniversal)
                .padding([.vertical, .leading], 16)
                .padding(.trailing, 68)
            
            VStack(alignment: .leading, spacing: 0) {
                Button(action: onFromTap) {
                    HStack {
                        Text(from.displayText.isEmpty ? "Откуда" : from.displayText)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(from.displayText.isEmpty ? .gray : .blackUniversal)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: onToTap) {
                    HStack {
                        Text(to.displayText.isEmpty ? "Куда" : to.displayText)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(to.displayText.isEmpty ? .gray : .blackUniversal)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
        }
        .overlay(alignment: .trailing) {
            Button(action: onSwap) {
                Image("ChangeButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
            .padding(.trailing, 16)
        }
    }
}
// MARK: - Preview

#Preview { ContentView() }
