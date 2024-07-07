import Foundation

public actor Poller {
    let interval: TimeInterval
    var task: Task<Void, Never>?
    var started: Bool = false

    /// Create a new poller with an interval specified in seconds
    public init(interval: TimeInterval) {
        self.interval = interval
    }

    func start(action: @escaping () async -> Void) {
        stop()
        task = Task {
            while !Task.isCancelled {
                await action()
                try? await Task.sleep(for: .seconds(interval))
            }
        }
        started = true
    }

    func stop() {
        task?.cancel()
        task = nil
        started = false
    }
}
