//
//  InstructionsView.swift
//  Twofy
//
//  Created by Brian Michel on 7/6/24.
//

import SwiftUI

struct InstructionsView: View {
    var grantAccessClicked: () -> Void

    var body: some View {
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Spacer()
                Button("Grant Access To Messages")
                {
                    grantAccessClicked()

                }
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

    private func instructionRow(index: Int, text: String, subtitle: String? = nil) -> some View {
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
}

#Preview {
    InstructionsView(grantAccessClicked: {})
}
