import Dependencies
import ManifestInstallerService
import SwiftUI

struct OnboardingView: View {
    @ObservedObject var onboarding: OnboardingViewModel
    @Environment(\.dismiss) var dismiss

    @State var selectedBrowser: NativeMessageSource = .arc

    var body: some View {
        VStack(alignment: .leading) {
            Text("To get started, select which browser you would like to use Twofy with.")
                .fixedSize(horizontal: false, vertical: true)
            GroupBox {
                VStack(alignment: .leading) {
                    Text("Preferred Browser").font(.headline)
                    Picker(selection: $selectedBrowser) {
                        ForEach(NativeMessageSource.allCases, id: \.self) { browser in
                            Text(browser.name)
                        }
                    } label: {}
                }
                .padding(3)
            }
            HStack {
                Spacer()
                Button {
                    Task {
                        try await onboarding.finishOnboarding(with: selectedBrowser)
                    }
                    dismiss()
                } label: {
                    Text("Select \(selectedBrowser.name)")
                }
            }
        }
        .frame(width: 300)
        .padding()
    }
}

#Preview {
    OnboardingView(onboarding: .init())
}
