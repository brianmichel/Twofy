//
//  ViewModel.swift
//  Twofy
//
//  Created by Brian Michel on 6/23/24.
//

import AppFeature
import Foundation
import MessageDatabaseListener

final class ViewModel: ObservableObject {
    @Published var messages = [Message]()

    private(set) var listener: MessageDatabaseListener?

    @Published private(set) var findingCodes: Bool = false
    private var findMessagesTask: Task<Void, (any Error)>?

    func setupListner(for path: URL) throws {
        listener = try MessageDatabaseListener(path: path)
    }

    func startFindingCodes() {
        guard let listener else { return }
        stopFindingCodes()

        findMessagesTask = Task {
            for try await messages in listener.stream {
                Task { @MainActor in
                    self.messages = messages.filter({ $0.extractedCode() != nil })
                }
            }
        }

        listener.start(lookback: .days(10))
        findingCodes = true
    }

    func stopFindingCodes() {
        findingCodes = false
        findMessagesTask?.cancel()
        findMessagesTask = nil
    }
}

extension ViewModel {
    static func stub() -> ViewModel {
        let model = ViewModel()
        model.messages = [
            .stub(id: 0, code: "34343"),
            .stub(id: 1, code: "333"),
            .stub(id: 2, code: "90809"),
            .stub(id: 3, code: "2391"),
            .stub(id: 4, code: "2919"),
            .stub(id: 5, code: "880723")
        ]

        return model
    }
}
