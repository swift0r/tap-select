// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import ComposableArchitecture
import SwiftUI

struct SelectionView: View {
    @Bindable var store: StoreOf<SelectionFeature>

    var body: some View {
        ZStack {
            MultiTouchMap(store: store)

            ForEach(store.touches) { touch in
                FingerCircleView(viewState: .init(touch: touch, isCountdown: store.phase.isCountdown))
            }
        }
        .background {
            LinearGradient(
                colors: [.cyan, .blue],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .overlay {
            idleView
        }
        .sheet(isPresented: $store.showAboutSheet.sending(\.showAboutSheet)) {
            TapSelectAboutView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var idleView: some View {
        if store.phase.isPreparing {
            LoadingView()
        } else if store.phase.isCollecting, store.touches.isEmpty {
            ZStack {
                DescriptionView()
                AboutButton {
                    store.send(.showAboutSheet(true))
                }
            }
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        ProgressView()
            .foregroundStyle(.white.opacity(0.2))
    }
}

private struct DescriptionView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("TapSelect")
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            Text("Place at least two fingers\non the screen")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding()
    }
}

private struct AboutButton: View {
    let action: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "person.bubble")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                .foregroundStyle(.white)
            }
            Spacer()
        }
    }
}
