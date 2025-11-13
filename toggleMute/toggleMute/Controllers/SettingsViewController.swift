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

        let recorder = KeyboardShortcuts.RecorderCocoa(for: .toggleMuteShortcut)
        recorder.translatesAutoresizingMaskIntoConstraints = false
        recorder.widthAnchor.constraint(greaterThanOrEqualToConstant: 130).isActive = true
        recorder.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
        shortcutSubView.addSubview(recorder)

        let muteOnlyRecorder = KeyboardShortcuts.RecorderCocoa(for: .muteOnlyShortcut)
        muteOnlyRecorder.translatesAutoresizingMaskIntoConstraints = false
        muteOnlyRecorder.widthAnchor.constraint(greaterThanOrEqualToConstant: 130).isActive = true
        muteOnlyRecorder.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
        muteOnlyShortcutSubView.addSubview(muteOnlyRecorder)

        let unmuteOnlyRecorder = KeyboardShortcuts.RecorderCocoa(for: .unmuteOnlyShortcut)
        unmuteOnlyRecorder.translatesAutoresizingMaskIntoConstraints = false
        unmuteOnlyRecorder.widthAnchor.constraint(greaterThanOrEqualToConstant: 130).isActive = true
        unmuteOnlyRecorder.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
        unmuteOnlyShortcutSubView.addSubview(unmuteOnlyRecorder)

        let pushToToggleRecorder = KeyboardShortcuts.RecorderCocoa(for: .pushToToggleShortcut)
        pushToToggleRecorder.translatesAutoresizingMaskIntoConstraints = false
        pushToToggleRecorder.widthAnchor.constraint(greaterThanOrEqualToConstant: 130).isActive = true
        pushToToggleRecorder.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
        pushToToggleShortcutSubView.addSubview(pushToToggleRecorder)
        
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
