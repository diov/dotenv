// Toggles Ghostty with cmd+escape. Ghostty's own `global:cmd+escape` binding
// can show the window but never hide it: while Ghostty is frontmost the key
// never reaches its keybinding handling. A Carbon hotkey is delivered no
// matter which app is frontmost.
import AppKit
import Carbon.HIToolbox

let bundleID = "com.mitchellh.ghostty"

func toggle() {
    let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first
    if let app, app.isActive {
        app.hide()
    } else if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
        // Activating through LaunchServices also unhides a hidden app and is
        // not subject to the activation limits of NSRunningApplication.activate.
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
    }
}

var hotKeyRef: EventHotKeyRef?
let status = RegisterEventHotKey(
    UInt32(kVK_Escape), UInt32(cmdKey),
    EventHotKeyID(signature: OSType(0x4748_5354), id: 1),
    GetApplicationEventTarget(), 0, &hotKeyRef)
guard status == noErr else {
    FileHandle.standardError.write("RegisterEventHotKey failed: \(status)\n".data(using: .utf8)!)
    exit(1)
}

var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in toggle(); return noErr }, 1, &spec, nil, nil)

NSApplication.shared.setActivationPolicy(.accessory)
NSApplication.shared.run()
