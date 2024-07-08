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

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    @State var hoveredCell: Int64 = -1
    @State var openPanelPresented = false
    private let openPanelDelegate = MessagesDatabaseOnlyDelegate()

    var body: some View {
        VStack {
            if let error = viewModel.error {
                Text(error.localizedDescription)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .background(Rectangle().fill(Color.red))
            }
            GroupBox {
                if viewModel.databaseFolder == nil {
                    InstructionsView {
                        openPanelPresented.toggle()
                    }
                } else if viewModel.messages.isEmpty {
                    noCodesView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [.init(.adaptive(minimum: 100))], content: {
                            ForEach(viewModel.messages) { message in
                                codeCell(for: message)
                            }
                            .animation(.default, value: viewModel.messages)
                        })
                        .padding(5)
                    }
                }
            }
            .padding()
        }.overlay(
            OpenPanel(
                isPresented: $openPanelPresented,
                selectedURL: $viewModel.databaseFolder,
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
                Toggle(isOn: $viewModel.findingCodes, label: {
                    Text(viewModel.findingCodes ? "Stop Polling" : "Start Polling")
                })
                .disabled(viewModel.listener == nil)
                .help("Toggle polling for new 2FA codes.")
            }
        }
        #if DEBUG
        .background(.red.opacity(0.4))
        #endif
    }

    private func noCodesView() -> some View {
        VStack {
            Image(systemName: "ellipsis.bubble.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
            Text("No Recent Codes")
                .monospaced()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func codeCell(for message: Message) -> some View {
        VStack {
            Text(hoveredCell == message.id ? message.extractedCode() ?? "···" : message.maskedCode())
                .font(.title.monospaced())
                .fontWeight(hoveredCell == message.id ? .regular : .black)
                .frame(maxWidth: .infinity)
                .padding()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText(countsDown: true))
            Text(formattedDate(message.date))
                .font(.footnote)
                .padding(.bottom, 5)
                .help(message.date.formatted())
        }
        .background(in: RoundedRectangle(cornerRadius: 4, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
        .onHover(perform: { hovering in
            withAnimation(.easeInOut) {
                hoveredCell = hovering ? message.id : -1
            }
        })
        .onTapGesture {
            viewModel.send(code: message.extractedCode()!)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short

        return formatter.localizedString(for: date, relativeTo: .now)
    }
}

#Preview {
    ContentView(viewModel: .stub())
}
