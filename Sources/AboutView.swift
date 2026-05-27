// Copyright © 2026 Dr. Stefan Lahme. All rights reserved.

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                SectionView(title: "About this App") {
                    Text("*TapSelect* is a fun way to randomly pick a person from a group, e.g. to chose a starting player for a board game 🎲. Just place your fingers on the screen and let the app do its magic ✨.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Divider()

                SectionView(title: "About the Developer") {
                    Text("I'm *Stefan*, a Principal iOS Engineer from Velbert/Germany. I love to build clean, well-architected apps using Swift, SwiftUI and modern frameworks 👨🏼‍💻.\n\nFollow me:")
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
                        LicenseRow(name: "swift-composable-architecture", version: "1.25.5")
                        LicenseRow(name: "swift-dependencies", version: "1.12.0")
                        LicenseRow(name: "swift-case-paths", version: "1.7.3")
                        LicenseRow(name: "swift-identified-collections", version: "1.1.1")
                        LicenseRow(name: "swift-clocks", version: "1.0.6")
                        LicenseRow(name: "swift-concurrency-extras", version: "1.3.2")
                        LicenseRow(name: "swift-navigation", version: "2.8.0")
                        LicenseRow(name: "swift-perception", version: "2.0.10")
                        LicenseRow(name: "swift-sharing", version: "2.8.0")
                        LicenseRow(name: "swift-custom-dump", version: "1.5.0")
                        LicenseRow(name: "combine-schedulers", version: "1.2.0")
                        LicenseRow(name: "xctest-dynamic-overlay", version: "1.9.0")
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
            .padding(24)
        }
    }
}

private struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
                .kerning(1.2)

            content
        }
    }
}

private struct LicenseRow: View {
    let name: String
    let version: String
    let owner: String

    init(name: String, version: String, owner: String = "pointfreeco") {
        self.name = name
        self.version = version
        self.owner = owner
    }

    var body: some View {
        Link(destination: URL(string: "https://github.com/\(owner)/\(name)")!) {
            HStack(alignment: .firstTextBaseline) {
                Text(name)
                    .font(.system(.footnote, design: .monospaced))
                Spacer()
                Text(version)
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

private extension Bundle {
    var versionString: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
}
