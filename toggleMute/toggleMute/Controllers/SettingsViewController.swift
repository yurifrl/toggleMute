// Author: Sascha Petrik

import Cocoa
import LaunchAtLogin
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleMuteShortcut = Self("toggleMuteShortcut", default: .init(.k, modifiers: [.command, .option]))
    static let muteOnlyShortcut = Self("muteOnlyShortcut")
    static let unmuteOnlyShortcut = Self("unmuteOnlyShortcut")
    static let pushToToggleShortcut = Self("pushToToggleShortcut")
}

class SettingsViewController: NSViewController {

    @IBOutlet var launchAtLoginCheckBox: NSButton!
    @IBOutlet var quitButton: NSButton!
    @IBOutlet weak var shortcutSubView: NSView!
    @IBOutlet weak var muteOnlyShortcutSubView: NSView!
    @IBOutlet weak var unmuteOnlyShortcutSubView: NSView!
    @IBOutlet weak var pushToToggleShortcutSubView: NSView!
    @IBOutlet weak var versionLabel: NSTextField!
    private var preferences: Preferences!
    let defaults = UserDefaults.standard

    func isKeyPresentInUserDefaults(key: String) -> Bool {

        return UserDefaults.standard.object(forKey: key) != nil

    }
    
    
    static func instantiate(with preferences: Preferences) -> SettingsViewController {
        
        let storyboard = NSStoryboard(name: "Controllers", bundle: nil)

        guard let settingsController = storyboard.instantiateController(withIdentifier: "SettingsController") as? SettingsViewController else {
            fatalError("Unable to find SettingsController in the storyboard.")
        }

        settingsController.preferences = preferences

        return settingsController

    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if(isKeyPresentInUserDefaults(key: "stringLocalVersion")) {
            let version = defaults.string(forKey: "stringLocalVersion") ?? "-"
            versionLabel.stringValue = "Version: \(version)"
        }
        
        launchAtLoginCheckBox.state = preferences.launchAtLoginEnabled ? .on : .off

        // Use UnifiedInputRecorder for both keyboard and controller input
        let recorder = UnifiedInputRecorder(for: .toggleMuteShortcut)
        recorder.translatesAutoresizingMaskIntoConstraints = false
        shortcutSubView.addSubview(recorder)
        NSLayoutConstraint.activate([
            recorder.leadingAnchor.constraint(equalTo: shortcutSubView.leadingAnchor),
            recorder.trailingAnchor.constraint(equalTo: shortcutSubView.trailingAnchor),
            recorder.topAnchor.constraint(equalTo: shortcutSubView.topAnchor),
            recorder.bottomAnchor.constraint(equalTo: shortcutSubView.bottomAnchor)
        ])

        let muteOnlyRecorder = UnifiedInputRecorder(for: .muteOnlyShortcut)
        muteOnlyRecorder.translatesAutoresizingMaskIntoConstraints = false
        muteOnlyShortcutSubView.addSubview(muteOnlyRecorder)
        NSLayoutConstraint.activate([
            muteOnlyRecorder.leadingAnchor.constraint(equalTo: muteOnlyShortcutSubView.leadingAnchor),
            muteOnlyRecorder.trailingAnchor.constraint(equalTo: muteOnlyShortcutSubView.trailingAnchor),
            muteOnlyRecorder.topAnchor.constraint(equalTo: muteOnlyShortcutSubView.topAnchor),
            muteOnlyRecorder.bottomAnchor.constraint(equalTo: muteOnlyShortcutSubView.bottomAnchor)
        ])

        let unmuteOnlyRecorder = UnifiedInputRecorder(for: .unmuteOnlyShortcut)
        unmuteOnlyRecorder.translatesAutoresizingMaskIntoConstraints = false
        unmuteOnlyShortcutSubView.addSubview(unmuteOnlyRecorder)
        NSLayoutConstraint.activate([
            unmuteOnlyRecorder.leadingAnchor.constraint(equalTo: unmuteOnlyShortcutSubView.leadingAnchor),
            unmuteOnlyRecorder.trailingAnchor.constraint(equalTo: unmuteOnlyShortcutSubView.trailingAnchor),
            unmuteOnlyRecorder.topAnchor.constraint(equalTo: unmuteOnlyShortcutSubView.topAnchor),
            unmuteOnlyRecorder.bottomAnchor.constraint(equalTo: unmuteOnlyShortcutSubView.bottomAnchor)
        ])

        let pushToToggleRecorder = UnifiedInputRecorder(for: .pushToToggleShortcut)
        pushToToggleRecorder.translatesAutoresizingMaskIntoConstraints = false
        pushToToggleShortcutSubView.addSubview(pushToToggleRecorder)
        NSLayoutConstraint.activate([
            pushToToggleRecorder.leadingAnchor.constraint(equalTo: pushToToggleShortcutSubView.leadingAnchor),
            pushToToggleRecorder.trailingAnchor.constraint(equalTo: pushToToggleShortcutSubView.trailingAnchor),
            pushToToggleRecorder.topAnchor.constraint(equalTo: pushToToggleShortcutSubView.topAnchor),
            pushToToggleRecorder.bottomAnchor.constraint(equalTo: pushToToggleShortcutSubView.bottomAnchor)
        ])

    }
    
    
    override func viewDidDisappear() {
        
        super.viewDidDisappear()
        NSApp.activate(ignoringOtherApps: true)
        
    }
    
    
    @IBAction func didTouchLaunchAtLogin(_ sender: NSButton) {
    
        preferences.launchAtLoginEnabled = sender.state == .on ? true : false
        LaunchAtLogin.isEnabled = preferences.launchAtLoginEnabled

    }
    
    
    @IBAction func didTouchClose(_ sender: Any) {
        
        NSApplication.shared.terminate(nil)
        
    }
    
}
