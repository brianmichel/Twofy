import Foundation
import SwiftUI

extension View {
    public func onHover(cursor: NSCursor) -> some View {
        onHover(perform: { hovering in
            if hovering {
                cursor.push()
            } else {
                cursor.pop()
            }
        })
    }
}
