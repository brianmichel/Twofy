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
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 100))], content: {
                    ForEach(viewModel.messages) { message in
                        Text(message.extractedCode() ?? "???")
                            .monospaced()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(in: RoundedRectangle(cornerRadius: 8, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                    }
                })
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    ContentView(viewModel: .stub())
}
