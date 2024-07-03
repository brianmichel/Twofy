# Twofy

An application and suite of browser extensions to relay incoming 2FA text messages into the non-Safari browser of your choice.

## Design Goals

I want an app that can apply the principle of least privilege to a set of functionality that means giving access to my entire Message.app database which contains all of my messages. This means that Twofy:

- Is sandboxed
- Does not allow incoming or outgoing network traffic
- Requires the user to grant access to the `~/Library/Messages` directory
- (Coming Soon) is notarized
- (Coming Soon) isolates un-sandboxable behavior to different XPC services

## Architecture

```mermaid
sequenceDiagram
    box Green Sandboxed
    participant App
    participant App-BrowserSupport (NativeMessageHost)
    end
    box Red Not Sandboxed
    participant App-ManifestInstaller (XPC)
    end
    box Blue Browser
    participant Web Page
    participant Browser Extension
    end
    App-->>App-ManifestInstaller (XPC): Install NativeMessageHost registrations (If Needed)
    App-ManifestInstaller (XPC)-->>File System: Copy Files
    App-ManifestInstaller (XPC)-->>App: Registrations installed
    Web Page-->>Browser Extension: Land on page with 2FA input field
    Browser Extension-->>App-BrowserSupport (NativeMessageHost): Waiting For 2FA
    App-BrowserSupport (NativeMessageHost)-->>App: Start Polling For Messages
    App-->>App-BrowserSupport (NativeMessageHost): Found Code '1234'
    App-BrowserSupport (NativeMessageHost)-->>Browser Extension: Received Code '1234'
    Browser Extension-->>Web Page: Show '1234' in UI below input field
```
