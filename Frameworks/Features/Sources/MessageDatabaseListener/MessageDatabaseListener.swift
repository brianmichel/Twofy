import Foundation
import GRDB

enum DatabaseListenerError: Error {
    case databasePathUnavailable
}

public final class MessageDatabaseListener {
    public enum LookbackDuration {
        case days(Int)
        case hours(Int)
        case minutes(Int)

        var argument: String {
            switch self {
            case let .days(days):
                return "-\(days) days"
            case let .hours(hours):
                return "-\(hours) hours"
            case let .minutes(minutes):
                return "-\(minutes) minutes"
            }
        }
    }

    private let databasePath: URL
    private let queue: DatabaseQueue
    private let streamComponents = AsyncThrowingStream<[Message], (any Error)>.makeStream()

    public lazy var stream: AsyncThrowingStream<[Message], (any Error)> = {
        return streamComponents.stream
    }()

    private(set) var pollingTask: Task<Void, Never>?

    public init(path: URL) throws {
        databasePath = path

        // Open the database in read-only mode
        var config = Configuration()
        config.readonly = true
        queue = try DatabaseQueue(path: path.path, configuration: config)
    }

    public func start(lookback: LookbackDuration = .minutes(15)) {
        stop()
        pollingTask = Task {
            let poller = Poller(interval: 5)
            await poller.start { [weak self] in
                guard let self else { return }
                do {
                    let messages = try queryMessage(in: queue, lookback: lookback)
                    streamComponents.continuation.yield(messages)
                } catch let error {
                    streamComponents.continuation.finish(throwing: error)
                }
            }
        }
    }

    public func stop() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    private func queryMessage(in db: DatabaseQueue, lookback: LookbackDuration) throws -> [Message] {
        try queue.read { db in
            // Query adapted from https://github.com/squatto/alfred-imessage-2fa/blob/master/find-messages.php
            let query = """
            select
                message.rowid AS id,
                ifnull(handle.uncanonicalized_id, chat.chat_identifier) AS sender,
                message.service,
                datetime(message.date / 1000000000 + strftime('%s', '2001-01-01'), 'unixepoch', 'localtime') AS message_date,
                message.text
            from
                message
                    left join chat_message_join on chat_message_join.message_id = message.ROWID
                    left join chat on chat.ROWID = chat_message_join.chat_id
                    left join handle on message.handle_id = handle.ROWID
            where
                message.is_from_me = 0
                and message.service is not 'iMessage'
                and message.text is not null
                and length(message.text) > 0
                and (
                    message.text glob '*[0-9][0-9][0-9]*'
                    or message.text glob '*[0-9][0-9][0-9][0-9]*'
                    or message.text glob '*[0-9][0-9][0-9][0-9][0-9]*'
                    or message.text glob '*[0-9][0-9][0-9][0-9][0-9][0-9]*'
                    or message.text glob '*[0-9][0-9][0-9]-[0-9][0-9][0-9]*'
                    or message.text glob '*[0-9][0-9][0-9][0-9][0-9][0-9][0-9]*'
                    or message.text glob '*[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*'
                )
                and datetime(message.date / 1000000000 + strftime('%s', '2001-01-01'), 'unixepoch', 'localtime')
                    >= datetime('now', ?, 'localtime')
            order by
            message.date desc;
            """
            return try Message.fetchAll(db, sql: query, arguments: [lookback.argument])
        }
    }
}
