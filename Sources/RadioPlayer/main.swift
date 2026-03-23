import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.regular) // Show in dock

// Must retain delegate — NSApplication.delegate is weak
let delegate = AppDelegate()
withExtendedLifetime(delegate) {
    app.delegate = delegate
    app.run()
}
