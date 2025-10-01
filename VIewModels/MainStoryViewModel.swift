import SwiftUI
import Combine

class MainStoryViewModel: ObservableObject {
    @Published var currentIndex: Int
    @Published var progresses: [CGFloat]
    @Published var isPaused = false
    @Published var timer: Timer.TimerPublisher
    @Published var cancellable: Cancellable?
    
    let stories: [Stories]
    private let secondsPerStory: TimeInterval = 10
    private let tick: TimeInterval = 0.05
    
    var currentStory: Stories {
        stories[currentIndex]
    }
    
    init(stories: [Stories], startIndex: Int = 0) {
        self.stories = stories
        self.currentIndex = max(0, min(startIndex, stories.count - 1))
        self.progresses = Array(repeating: 0, count: stories.count)
        self.timer = Timer.publish(every: tick, on: .main, in: .common)
    }
    
    func startTimer() {
        timer = Timer.publish(every: tick, on: .main, in: .common)
        cancellable = timer.connect()
    }
    
    func stopTimer() {
        cancellable?.cancel()
    }
    
    func resetTimer() {
        cancellable?.cancel()
        timer = Timer.publish(every: tick, on: .main, in: .common)
        cancellable = timer.connect()
    }
    
    func tickUpdate(onComplete: (() -> Void)? = nil) {
        guard !isPaused else { return }
        let increment = CGFloat(tick / secondsPerStory)
        progresses[currentIndex] += increment
        if progresses[currentIndex] >= 1 {
            progresses[currentIndex] = 1
            nextStory(onComplete: onComplete)
        }
    }
    
    func nextStory(onComplete: (() -> Void)? = nil) {
        if currentIndex + 1 < stories.count {
            currentIndex += 1
        } else {
            onComplete?()
        }
    }
    
    func prevStory() {
        if currentIndex > 0 {
            progresses[currentIndex] = 0
            currentIndex -= 1
        } else {
            progresses[currentIndex] = 0
        }
    }
}
