import AppKit
import SwiftUI
import UniformTypeIdentifiers

public struct OpenPanel: NSViewRepresentable {
    @Binding public var isPresented: Bool
    @Binding public var selectedURL: URL?

    public var directoryURL: URL? = nil
    public var allowedContentTypes: [UTType] = []
    public var allowsMultipleSelection = false
    public var canChooseDirectories = false
    public var canChooseFiles = true
    public var title: String = ""
    public var message: String = ""
    public var prompt: String = ""
    public var delegate: (any NSOpenSavePanelDelegate)?

    public init(
        isPresented: Binding<Bool>,
        selectedURL: Binding<URL?> = .constant(nil),
        directoryURL: URL? = nil,
        allowedContentTypes: [UTType] = [],
        allowsMultipleSelection: Bool = false,
        canChooseDirectories: Bool = false,
        canChooseFiles: Bool = true,
        title: String = "",
        message: String = "",
        prompt: String = "",
        delegate: (any NSOpenSavePanelDelegate)? = nil
    ) {
        _isPresented = isPresented
        _selectedURL = selectedURL
        self.directoryURL = directoryURL
        self.allowedContentTypes = allowedContentTypes
        self.allowsMultipleSelection = allowsMultipleSelection
        self.canChooseDirectories = canChooseDirectories
        self.canChooseFiles = canChooseFiles
        self.title = title
        self.message = message
        self.prompt = prompt
        self.delegate = delegate
    }

    public func makeNSView(context: Context) -> NSView {
        NSView()
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented {
            let openPanel = NSOpenPanel()
            openPanel.delegate = delegate
            openPanel.directoryURL = directoryURL
            openPanel.allowedContentTypes = allowedContentTypes
            openPanel.allowsMultipleSelection = allowsMultipleSelection
            openPanel.canChooseDirectories = canChooseDirectories
            openPanel.canChooseFiles = canChooseFiles
            openPanel.title = title
            openPanel.message = message
            openPanel.prompt = prompt
            openPanel.delegate = delegate

            openPanel.beginSheetModal(for: nsView.window!) { response in
                if response == .OK {
                    selectedURL = openPanel.url
                }
                isPresented = false
            }
        }
    }
}
