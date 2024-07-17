import SwiftUI

struct ProgressDots: View {
    private let dotSpacing: CGFloat = 15
    private let dotsScalingFactor: CGFloat = 2.5
    private let controlHeight: CGFloat = 13
    
    let numberOfSteps: Int

    @Binding var currentIndex: Int
    @State private var capsuleWidth: CGFloat = 0

    var body: some View {
        Group {
            if numberOfSteps > 0 {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .foregroundColor(Color(nsColor: NSColor.controlAccentColor))
                            .frame(width: capsuleWidth, height: controlHeight)
                        HStack(spacing: 15) {
                            ForEach(0..<numberOfSteps, id: \.self) { index in
                                Ellipse()
                                    .frame(width: controlHeight/dotsScalingFactor, height: controlHeight/dotsScalingFactor)
                                    .opacity(index < currentIndex ? 0.4 : 1.0)
                                    .foregroundStyle(index <= currentIndex ? .white : .primary)
                            }
                        }
                        .padding(4)
                    }
                    .onAppear {
                        updateCapsuleWidth()
                    }
                }
        }
        .onChange(of: currentIndex) { _ in
            withAnimation {
                updateCapsuleWidth()
            }
        }
        .frame(height: controlHeight)
        .padding(5)
    }

    private func updateCapsuleWidth() {
        if currentIndex == 0 {
            capsuleWidth = controlHeight
        } else {
            capsuleWidth = controlHeight + CGFloat((20.5 * Double(currentIndex)))
        }
    }
}

#Preview("Three Steps") {
    ProgressDots(numberOfSteps: 5, currentIndex: .constant(4))
}
#Preview("10 Steps") {
    ProgressDots(numberOfSteps: 10, currentIndex: .constant(2))
}
