import SwiftUI
import Combine

struct MainStoryView: View {
    @StateObject private var viewModel: MainStoryViewModel
    private let onClose: (() -> Void)?
    
    init(
        stories: [Stories] = [.story1, .story2, .story3, .story4, .story5, .story6],
        startIndex: Int = 0,
        onClose: (() -> Void)? = nil
    ) {
        self.onClose = onClose
        self._viewModel = StateObject(wrappedValue: MainStoryViewModel(stories: stories, startIndex: startIndex))
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                let imageHeight = geo.size.height
                
                ZStack {
                    Group {
                        if let img = viewModel.currentStory.backgroundImage {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: imageHeight)
                                .frame(maxWidth: .infinity)
                        } else {
                            viewModel.currentStory.backgroundColor
                                .frame(height: imageHeight)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(width: geo.size.width)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: geo.size.width, height: imageHeight)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                                .onEnded { value in
                                    if value.translation.height > 50 {
                                        onClose?()
                                    } else if value.translation.width < -50 {
                                        viewModel.nextStory { onClose?() }
                                    } else if value.translation.width > 50 {
                                        viewModel.prevStory()
                                    }
                                }
                        )
                        .onTapGesture { location in
                            let half = geo.size.width / 2
                            if location.x < half {
                                viewModel.prevStory()
                            } else {
                                viewModel.nextStory { onClose?() }
                            }
                            viewModel.resetTimer()
                        }
                        .onLongPressGesture(minimumDuration: 0.2) {
                            viewModel.isPaused = true
                        } onPressingChanged: { pressing in
                            if !pressing { viewModel.isPaused = false }
                        }
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            ForEach(viewModel.stories.indices, id: \.self) { i in
                                GeometryReader { g in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white)
                                            .frame(height: 6)
                                        Capsule()
                                            .fill(Color.blueUniversal)
                                            .frame(width: g.size.width * viewModel.progresses[i], height: 6)
                                    }
                                }
                                .frame(height: 6)
                            }
                        }
                        .padding([.horizontal, .bottom], 12)
                        .padding(.top, 28)
                        
                        HStack {
                            Spacer()
                            CloseButton { onClose?() }
                                .contentShape(Rectangle())
                                .padding(.trailing, 12)
                        }
                        
                        Spacer()
                    }
                    .frame(width: geo.size.width, height: imageHeight, alignment: .top)
                    
                    VStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 16) {
                            Text(viewModel.currentStory.title)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Text(viewModel.currentStory.description)
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                    .frame(width: geo.size.width, height: imageHeight, alignment: .bottomLeading)
                }
                .padding(.top, 7)
                .padding(.bottom, 17)
                .frame(height: imageHeight)
            }
        }
        .onAppear {
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .onReceive(viewModel.timer) { _ in
            viewModel.tickUpdate { onClose?() }
        }
    }
}

#Preview {
    MainStoryView()
}
