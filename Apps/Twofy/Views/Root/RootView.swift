import AppFeature
import MessageDatabaseListener
import SwiftUI
import Utilities

final class MessagesDatabaseOnlyDelegate: NSObject, NSOpenSavePanelDelegate {
    private let allowedURL: URL = .messageDatabasePath

    func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
        url == allowedURL
    }
}

struct RootView: View {
    @ObservedObject var appModel: AppModel
    @State var hoveredCell: Int64 = -1
    @State var openPanelPresented = false
    private let openPanelDelegate = MessagesDatabaseOnlyDelegate()

    var body: some View {
        VStack {
            if let error = appModel.error {
                Text(error.localizedDescription)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .background(Rectangle().fill(Color.red))
            }
            GroupBox {
                if let codesViewModel = appModel.codesViewModel {
                    CodesView(model: codesViewModel)
                } else {
                    InstructionsView {
                        openPanelPresented.toggle()
                    }
                }
            }
            .padding()
        }.overlay(
            OpenPanel(
                isPresented: $openPanelPresented,
                selectedURL: $appModel.databaseFolder,
                directoryURL: .messageDatabasePath,
                allowsMultipleSelection: false,
                canChooseDirectories: true,
                canChooseFiles: false,
                message: NSLocalizedString("Click 'Open' to grant access to the Messages folder.", comment: "Title of the open panel indicating that clicking open will grant access to the Messages folder."),
                prompt: NSLocalizedString("Grant Access", comment: "Prompt of the open panel used to grant access to the messages folder."),
                delegate: openPanelDelegate
            )
            // This should be disabled to ensure that pointer
            // events make their way to the various cells.
            .disabled(true)
        )
        .toolbar {
            ToolbarItemGroup {
                Button {
                    // Do nothing for right now
                } label: {
                    Image(systemName: "gearshape.fill")
                }

            }
        }
        .sheet(isPresented: appModel.settings.$needsOnboarding, content: {
            OnboardingView(onboarding: appModel.onboarding)
        })
    }
}

#Preview {
    return RootView(appModel: {
        let model: AppModel = .stub()
        model.databaseFolder = URL(fileURLWithPath: "/dev/null")
        return model
    }())
}
