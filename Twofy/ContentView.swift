import AppFeature
import MessageDatabaseListener
import SwiftUI

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
            HStack {
                Text(viewModel.databaseFolder?.path(percentEncoded: false) ?? "No folder selected")
                    .monospaced()
                Spacer()
                Toggle(isOn: $viewModel.findingCodes, label: {
                    Text("Monitor")
                })
                .toggleStyle(.switch)
                .disabled(viewModel.listener == nil)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            GroupBox {
                if viewModel.databaseFolder == nil {
                    instructionsViews()
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
            .padding(.horizontal)
            .padding(.bottom)
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
    }

    private func instructionsViews() -> some View {
        func instructionRow(index: Int, text: String, subtitle: String? = nil) -> some View {
            HStack(alignment: .firstTextBaseline) {
                Text("\(index)")
                    .frame(width: 20, height: 20)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(text)
                    if let subtitle {
                        Text(subtitle)
                            .foregroundStyle(.gray)
                            .font(.subheadline)
                    }
                }
            }
            .font(.headline)
        }
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Spacer()
                Button("Grant Access To Messages")
                {
                    openPanelPresented.toggle()

                }.disabled(viewModel.findingCodes)
                Spacer()
            }
            Spacer().frame(height: 10)
            instructionRow(
                index: 1,
                text: "Click the ‘Grant Access To Mesages’ button to grant access to the Messages folder on your computer."
            )
            instructionRow(
                index: 2, 
                text: "Click the ‘Grant Access’ button in the open panel when it presents itself.",
                subtitle: "We've automatically located your messages folder so you just have to click this button."
            )
            instructionRow(index: 3, text: "Click the ‘Start’ button to begin monitoring for incoming 2FA messages.")
        }
        .frame(width: 300)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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
