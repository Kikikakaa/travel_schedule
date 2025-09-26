import SwiftUI
import Combine

struct MainStoryView: View {
    private let stories: [Stories]
    private let onClose: (() -> Void)?
    private let secondsPerStory: TimeInterval = 10
    private let tick: TimeInterval = 0.05
    
    @State private var currentIndex: Int
    @State private var progresses: [CGFloat]
    @State private var timer: Timer.TimerPublisher
    @State private var cancellable: Cancellable?
    @State private var isPaused = false
    
    init(
        stories: [Stories] = [.story1, .story2, .story3, .story4, .story5, .story6],
        startIndex: Int = 0,
        onClose: (() -> Void)? = nil
    ) {
        self.stories = stories
        self._currentIndex = State(initialValue: max(0, min(startIndex, stories.count-1)))
        self._progresses = State(initialValue: Array(repeating: 0, count: stories.count))
        self.onClose = onClose
        self._timer = State(initialValue: Timer.publish(every: tick, on: .main, in: .common))
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                let imageHeight = geo.size.height
                
                ZStack {
                    Group {
                        if let img = stories[currentIndex].backgroundImage {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: imageHeight)
                                .frame(maxWidth: .infinity)
                        } else {
                            stories[currentIndex].backgroundColor
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
                                        nextStory()
                                    } else if value.translation.width > 50 {
                                        prevStory()
                                    }
                                }
                        )
                        .onTapGesture { location in
                            let half = geo.size.width / 2
                            if location.x < half { prevStory() } else { nextStory() }
                            resetTimer()
                        }
                        .onLongPressGesture(minimumDuration: 0.2) {
                            isPaused = true
                        } onPressingChanged: { pressing in
                            if !pressing { isPaused = false }
                        }
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            ForEach(stories.indices, id: \.self) { i in
                                GeometryReader { g in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white)
                                            .frame(height: 6)
                                        Capsule()
                                            .fill(Color.blueUniversal)
                                            .frame(width: g.size.width * progresses[i], height: 6)
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
                            Text(stories[currentIndex].title)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Text(stories[currentIndex].description)
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
            timer = Timer.publish(every: tick, on: .main, in: .common)
            cancellable = timer.connect()
        }
        .onDisappear { cancellable?.cancel() }
        .onReceive(timer) { _ in guard !isPaused else { return }; tickUpdate() }
        
    }
    
    // MARK: - Logic
    private func tickUpdate() {
        let increment = CGFloat(tick / secondsPerStory)
        progresses[currentIndex] += increment
        if progresses[currentIndex] >= 1 {
            progresses[currentIndex] = 1
            nextStory()
        }
    }
    
    private func nextStory() {
        if currentIndex + 1 < stories.count {
            currentIndex += 1
        } else {
            onClose?()
        }
    }
    
    private func prevStory() {
        if currentIndex > 0 {
            progresses[currentIndex] = 0
            currentIndex -= 1
        } else {
            progresses[currentIndex] = 0
        }
    }
    
    private func resetTimer() {
        cancellable?.cancel()
        timer = Timer.publish(every: tick, on: .main, in: .common)
        cancellable = timer.connect()
    }
}

#Preview {
    MainStoryView()
}
