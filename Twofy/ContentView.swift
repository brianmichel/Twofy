//
//  ContentView.swift
//  Twofy
//
//  Created by Brian Michel on 6/23/24.
//

import SwiftUI

enum Colors {
    static let green: NSColor = #colorLiteral(red: 0.1906888783, green: 0.8113146424, blue: 0.3471082449, alpha: 1)
}

struct ContentView: View {
    @State var error: String = "No Error"
    @State var databasePath: String = ""
    @State var hoveredCell: Int64 = -1

    @ObservedObject var viewModel: ViewModel
    var body: some View {
        VStack {
            Text(error)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Rectangle().fill(Color.red))
            HStack {
                Button("Select File")
                {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    if panel.runModal() == .OK, let url = panel.url {
                        do {
                            try viewModel.setupListner(for: url)
                            self.error = "Setup listener"
                            self.databasePath = url.path(percentEncoded: false)
                        } catch {
                            self.error = error.localizedDescription
                            print("Unable to setup listner \(error)")
                        }
                    }
                }
                Text(databasePath)
                    .monospaced()
                Spacer()
                HStack {
                    Button("Start") {
                        viewModel.startFindingCodes()
                    }.disabled(viewModel.listener != nil && viewModel.findingCodes)
                    Button("Stop") {
                        viewModel.stopFindingCodes()
                    }.disabled(viewModel.listener != nil && !viewModel.findingCodes)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            VStack(alignment: .center) {
                if viewModel.messages.isEmpty {
                    Text("No Recent Codes")
                        .monospaced()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [.init(.adaptive(minimum: 100))], content: {
                            ForEach(viewModel.messages) { message in
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
                                .clipped()
                                .background(in: RoundedRectangle(cornerRadius: 4, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                                )
                                .onHover(perform: { hovering in
                                    withAnimation(.easeInOut) {
                                        hoveredCell = hovering ? message.id : -1
                                    }
                                })
                            }
                        })
                        .padding(5)
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor))
                .stroke(Color(NSColor.controlColor), style: StrokeStyle(lineWidth: 0.8, lineCap: .round, lineJoin: .round, miterLimit: 10, dash: [5], dashPhase: 0))
            )
            .padding(.horizontal)
            .padding(.bottom)
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
