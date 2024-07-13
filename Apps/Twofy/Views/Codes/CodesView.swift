import MessageDatabaseListener
import SwiftUI

struct CodesView: View {
    @StateObject var model: CodesViewModel
    @State var hoveredCell: Int64 = -1

    var body: some View {
        Group {
            if model.messages.isEmpty {
                noCodesView()
            } else {
                ScrollView {
                    LazyVGrid(columns: [.init(.adaptive(minimum: 100))], content: {
                        ForEach(model.messages) { message in
                            codeCell(for: message)
                        }
                        .animation(.default, value: model.messages)
                    })
                    .padding(5)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Toggle(isOn: $model.findingCodes, label: {
                    Text(model.findingCodes ? "Stop Polling" : "Start Polling")
                })
                .help("Toggle polling for new 2FA codes.")
            }
        }
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
            model.send(code: message.extractedCode()!)
        }
        .onHover(cursor: .pointingHand)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short

        return formatter.localizedString(for: date, relativeTo: .now)
    }
}

#Preview {
    CodesView(model: .stub())
}
