import Foundation

extension String {
    /// Identifier of the serivce responsible for installing
    /// manifest files into the various `NativeMessageHosts`
    /// directories of the selected browser.
    static public let manifestInstaller = "me.foureyes.Twofy.ManifestInstaller"

    /// Identifier of the serivce responsible for connecting with the browser
    /// and pushing codes through as they get queried from the database polling
    /// mechanism in another process.
    static public let browserSupport = "me.foureyes.Twofy.BrowserSupport"
}
