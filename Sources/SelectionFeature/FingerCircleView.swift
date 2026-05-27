// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import SwiftUI

struct FingerCircleView: View {
    let viewState: ViewState

    var body: some View {
        ZStack {
            if viewState.isFilled {
                Circle()
                    .fill(Color.white)
            } else {
                Circle()
                    .strokeBorder(Color.white, lineWidth: viewState.strokeWidth)
            }
        }
        .frame(width: viewState.size, height: viewState.size)
        .shadow(color: viewState.shadowColor, radius: viewState.shadowRadius)
        .scaleEffect(viewState.scale)
        .animation(viewState.pulseAnimation, value: viewState.isPulsing)
        .opacity(viewState.opacity)
        .animation(viewState.opacityAnimation, value: viewState.opacity)
        .position(viewState.position)
    }
}

extension FingerCircleView {
    struct ViewState {
        let position: CGPoint
        let size: CGFloat
        let strokeWidth: CGFloat
        let isFilled: Bool
        let shadowColor: Color
        let shadowRadius: CGFloat
        let scale: CGFloat
        let opacity: CGFloat
        let isPulsing: Bool
        let pulseAnimation: Animation
        let opacityAnimation: Animation

        init(touch: TouchPoint, isCountdown: Bool) {
            position = touch.position
            size = touch.isSelected ? 120 : 100
            strokeWidth = 10
            isFilled = touch.isSelected
            shadowColor = touch.isSelected ? .white : (isCountdown ? .white.opacity(0.5) : .clear)
            shadowRadius = touch.isSelected ? 30 : (isCountdown ? 20 : 0)
            isPulsing = touch.isPulsing && !touch.isSelected
            scale = isPulsing ? 1.12 : (touch.isSelected ? 1.15 : 1.0)
            opacity = touch.isVisible ? 1 : 0
            pulseAnimation = isPulsing ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .easeInOut(duration: 0.3)
            opacityAnimation = .easeInOut(duration: 0.3)
        }
    }
}
