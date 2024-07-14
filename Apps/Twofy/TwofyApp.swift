import AppFeature
import SwiftUI

@main
struct TwofyApp: App {
    @NSApplicationDelegateAdaptor var appDelegate: TwofyAppDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView(appModel: appDelegate.appModel)
                .frame(minWidth: 500, maxWidth: 500, minHeight: 400, maxHeight: 400)
            #if DEBUG
                .navigationTitle("Twofy (Debug)")
            #endif
        }
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environmentObject(appDelegate.appModel.settings)
        }
    }
}
