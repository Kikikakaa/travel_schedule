import SwiftUI

struct StoryView: View {
    let story: Stories
    
    var body: some View {
        ZStack {
            story.backgroundColor
                .ignoresSafeArea()
            
            if let bg = story.backgroundImage {
                Image(uiImage: bg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            
            LinearGradient(
                colors: [Color.black.opacity(0.45), Color.clear],
                startPoint: .bottom, endPoint: .center
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 10) {
                    Text(story.title)
                        .font(.bold34)
                        .foregroundColor(.white)
                    Text(story.description)
                        .font(.regular20)
                        .lineLimit(3)
                        .foregroundColor(.white)
                }
                .padding(.init(top: 0, leading: 16, bottom: 40, trailing: 16))
            }
        }
    }
}

#Preview {
    StoryView(story: .story2)
}
