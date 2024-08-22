import Dependencies
import ManifestInstallerService
import SwiftUI

struct GeneralView: View {
    @Dependency(\.settings) var settings: SettingsModel

    public var body: some View {
        Form {
            Section {
                Toggle(isOn: settings.$startOnLogin, label: {
                    Text("Start at login")
                })
                HStack {
                    Text("Updates")
                    Spacer()
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Check for updates")
                    })
                }
            }
            .disabled(true)
            Section("Messages") {
                VStack(alignment: .leading) {
                    Slider(value: settings.$pollingInterval, in: 10...30, step: 5, label: {
                        VStack(alignment: .leading) {
                            Text("Check Frequency").font(.headline)
                            Text("\(settings.pollingInterval.formatted()) seconds")
                                .monospaced()
                                .font(.caption)
                                .contentTransition(.numericText())
                                .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/, value: settings.pollingInterval)
                        }
                    }, minimumValueLabel: {
                        Text("10")
                    }, maximumValueLabel: {
                        Text("30")
                    })
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "bolt.fill")
                        Text("A lower polling interval will retreive messages faster, but may use more energy since it's asking for messages more frequently.")
                            .font(.footnote)
                    }
                    .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading) {
                    Slider(value: settings.$lookbackWindow, in: 1...5, step: 1, label: {
                        VStack(alignment: .leading) {
                            Text("Lookback Window").font(.headline)
                            Text("\(settings.lookbackWindow.formatted()) minutes")
                                .monospaced()
                                .font(.caption)
                                .contentTransition(.numericText())
                                .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/, value: settings.lookbackWindow)
                        }
                    }, minimumValueLabel: {
                        Text("1")
                    }, maximumValueLabel: {
                        Text("5")
                    })
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("A longer lookback window will let you collect more previously received codes in the application. A shorter window will clear out codes from the application that are no longer useful.")
                            .font(.footnote)
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(height: 350)
    }
}

struct BrowsersView: View {
    @Dependency(\.settings) var settings: SettingsModel

    @State var browsers: [NativeMessageSourceAvailability] = []

    var body: some View {
        Form {
            Section {
                List {
                    ForEach(browsers, id: \.source) { browser in
                        HStack {
                            Image(systemName: "app.dashed")
                                .resizable()
                                .fontWeight(.thin)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                            VStack(alignment: .leading) {
                                Text(browser.source.name)
                                    .font(.headline)
                                Group {
                                    if browser.defaultBrowser {
                                        Text("Default Browser")
                                            .font(.footnote)
                                    }
                                }

                            }
                            Spacer()
                            Button(action: {
                                Task {
                                    do {
                                        try await settings.installManifest(for: browser.source)
                                    } catch {
                                        fatalError("Error installing manifest: \(error)")
                                    }
                                }
                            }, label: {
                                Text(buttonText(for: browser))
                            })
                            .disabled(browser.installationStatus == .notInstalled)
                            .help(helpText(for: browser))
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Available Browsers")
                    Spacer()
                    Button(action: {
                        updateBrowsers()
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                    })
                }
            }
        }
        .formStyle(.grouped)
        .onAppear(perform: {
            updateBrowsers()
        })
    }

    private func helpText(for item: NativeMessageSourceAvailability) -> String {
        switch item.installationStatus {
        case .installed:
            return "Install Twofy manifest to enable communication with extension."
        case .installedWithHostManifest:
            return "Manifest has already been installed for this browser."
        case .notInstalled:
            return "This browser is not installed."
        }
    }

    private func buttonText(for item: NativeMessageSourceAvailability) -> String {
        switch item.installationStatus {
        case .installed:
            return "Install Manifest"
        case .installedWithHostManifest:
            return "Reinstall Manifest"
        case .notInstalled:
            return "Unavailable"
        }
    }

    private func updateBrowsers() {
        Task {
            do {
                browsers = try await settings.fetchAvailableBrowsers()
            } catch {
                logger.error("Unable to refresh browser list: \(error)")
            }
        }
    }
}

struct AdvancedView: View {
    @Dependency(\.settings) var settings

    var body: some View {
        Form {
            Section("Options") {
                List {
                    HStack {
                        Text("Reset Onboarding")
                        Spacer()
                        Button {
                            settings.needsOnboarding = true
                        } label: {
                            Text("Reset")
                        }
                    }
                }
            }
        }.formStyle(.grouped)
    }
}

public struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, browsers, advanced
    }

    public init() {}

    public var body: some View {
        TabView {
            GeneralView()
                .tabItem {
                    Label("General", systemImage: "switch.2")
                }
                .tag(Tabs.general)
            BrowsersView()
                .tabItem {
                    Label("Browsers", systemImage: "macwindow")
                }
                .tag(Tabs.browsers)
            AdvancedView()
                .tabItem {
                    Label("Advanced", systemImage: "gearshape.2.fill")
                }
        }
        .frame(width: 375)
    }
}

#Preview("Main") {
    SettingsView()
}

#Preview("Browsers") {
    BrowsersView()
}

#Preview("General") {
    GeneralView()
}

#Preview("Advanced") {
    AdvancedView()
}
