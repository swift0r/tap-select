// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import About
import SwiftUI

struct TapSelectAboutView: View {
    var body: some View {
        AboutView {
            SectionView(title: "About this App") {
                Text("*TapSelect* is a fun way to randomly pick a person from a group, e.g. to chose a starting player for a board game 🎲. Just place your fingers on the screen and let the app do its magic ✨.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Divider()

            SectionView(title: "About the Developer") {
                Text("I'm *Stefan*, an iOS Engineer from Velbert, Germany. I love to build clean, well-architected apps using Swift, SwiftUI, and modern frameworks 👨🏼‍💻.\n\nFollow me:")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Link(destination: URL(string: "https://www.linkedin.com/in/stefan-lahme/")!) {
                    Label("LinkedIn", systemImage: "link")
                        .font(.body.bold())
                }

                Link(destination: URL(string: "https://github.com/swift0r/tap-select")!) {
                    Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                        .font(.body.bold())
                }
            }

            Divider()

            SectionView(title: "Acknowledgements") {
                VStack(alignment: .leading, spacing: 10) {
                    LicenseRow(name: "swift-composable-architecture", version: "1.25.5", owner: "pointfreeco")
                    LicenseRow(name: "swift-dependencies", version: "1.12.0", owner: "pointfreeco")
                    LicenseRow(name: "swift-case-paths", version: "1.7.3", owner: "pointfreeco")
                    LicenseRow(name: "swift-identified-collections", version: "1.1.1", owner: "pointfreeco")
                    LicenseRow(name: "swift-clocks", version: "1.0.6", owner: "pointfreeco")
                    LicenseRow(name: "swift-concurrency-extras", version: "1.3.2", owner: "pointfreeco")
                    LicenseRow(name: "swift-navigation", version: "2.8.0", owner: "pointfreeco")
                    LicenseRow(name: "swift-perception", version: "2.0.10", owner: "pointfreeco")
                    LicenseRow(name: "swift-sharing", version: "2.8.0", owner: "pointfreeco")
                    LicenseRow(name: "swift-custom-dump", version: "1.5.0", owner: "pointfreeco")
                    LicenseRow(name: "combine-schedulers", version: "1.2.0", owner: "pointfreeco")
                    LicenseRow(name: "xctest-dynamic-overlay", version: "1.9.0", owner: "pointfreeco")
                    LicenseRow(name: "About", version: "1.0.0", owner: "swift0r")
                    LicenseRow(name: "StoreKitClient", version: "1.0.0", owner: "swift0r")
                }
            }

            Divider()

            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("Designed and developed with ❤️")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(Bundle.main.versionString)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            }
            .padding(.bottom, 8)
        }
    }
}
