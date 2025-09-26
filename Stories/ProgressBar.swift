import SwiftUI

extension CGFloat {
    static let progressBarCornerRadius: CGFloat = 6
    static let progressBarHeight: CGFloat = 6
}

struct ProgressBar: View {
    let numberOfSections: Int
    let progress: CGFloat

    var body: some View {
        // Используем `GeometryReader` для получения размеров экрана
        GeometryReader { geometry in
            // Используем `ZStack` для отображения белой подложки прогресс бара и синей полоски прогресса
            ZStack(alignment: .leading) {
                // Белая подложка прогресс бара
                RoundedRectangle(cornerRadius: .progressBarCornerRadius)
                    .frame(width: geometry.size.width, height: .progressBarHeight)
                    .foregroundColor(.white)

                // Синяя полоска текущего прогресса
                RoundedRectangle(cornerRadius: .progressBarCornerRadius)
                    .frame(
                        // Ширина прогресса зависит от текущего прогресса.
                        // Используем `min` на случай, если `progress` > 1
                        width: min(
                            progress * geometry.size.width,
                            geometry.size.width
                        ),
                        height: .progressBarHeight
                    )
                    .foregroundColor(.progressBarFill)
            }
            // Добавляем маску
            .mask {
                MaskView(numberOfSections: numberOfSections)
            }
        }
    }
}


struct MaskFragmentView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: .progressBarCornerRadius)
            .fixedSize(horizontal: false, vertical: true)
            .frame(height: .progressBarHeight)
            .foregroundStyle(.white)
    }
}


#Preview {
    Color.story1Background
        .ignoresSafeArea()
        .overlay(
            ProgressBar(numberOfSections: 5, progress: 0.5)
                .padding()
        )
} 
