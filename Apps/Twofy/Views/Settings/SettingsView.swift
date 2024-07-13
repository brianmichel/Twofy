import ManifestInstallerService
import SwiftUI

struct GeneralView: View {
    @EnvironmentObject var settings: SettingsModel

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $settings.startOnLogin, label: {
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
                    Slider(value: $settings.pollingInterval, in: 10...30, step: 5, label: {
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
                    Slider(value: $settings.lookbackWindow, in: 1...5, step: 1, label: {
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
    @EnvironmentObject var settings: SettingsModel

    var body: some View {
        Form {
            Section {
                List {
                    ForEach(NativeMessageSource.allCases, id: \.self) { source in
                        HStack {
                            Image(systemName: "app.dashed")
                                .resizable()
                                .fontWeight(.thin)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                            VStack(alignment: .leading) {
                                Text(source.name)
                                    .font(.headline)
                                Group {
                                    if source == .arc {
                                        Text("Default Browser")
                                            .font(.footnote)
                                    }
                                }

                            }
                            Spacer()
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Text("Details")
                            })
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Available Browsers")
                    Spacer()
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "arrow.clockwise")
                    })
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, browsers
    }

    var body: some View {
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
        }
        .environmentObject(SettingsModel())
        .frame(width: 375)
    }
}

#Preview("Main") {
    SettingsView()
        .environmentObject(SettingsModel())
}

#Preview("Browsers") {
    BrowsersView()
        .environmentObject(SettingsModel())
}

#Preview("General") {
    GeneralView()
        .environmentObject(SettingsModel())
}
