// Author: Sascha Petrik

import Cocoa
import GameController
import KeyboardShortcuts

class GameControllerManager {

    static let shared = GameControllerManager()
    private var controllers: [GCController] = []
    private let defaults = UserDefaults.standard
    private var touchBarController: TouchBarController?

    // Recording state
    private var isRecording = false
    private var recordingFor: KeyboardShortcuts.Name?
    private var onButtonRecorded: ((String) -> Void)?

    private init() {}

    func setup(with touchBarController: TouchBarController) {
        self.touchBarController = touchBarController

        // Start monitoring for controller connections
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidConnect),
            name: .GCControllerDidConnect,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidDisconnect),
            name: .GCControllerDidDisconnect,
            object: nil
        )

        // Check for already connected controllers
        controllers = GCController.controllers()
        controllers.forEach { setupController($0) }
    }

    @objc private func controllerDidConnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        controllers.append(controller)
        setupController(controller)
        print("Controller connected: \(controller.vendorName ?? "Unknown")")
    }

    @objc private func controllerDidDisconnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        controllers.removeAll { $0 == controller }
        print("Controller disconnected: \(controller.vendorName ?? "Unknown")")
    }

    private func setupController(_ controller: GCController) {
        // Handle extended gamepad (most modern controllers)
        if let gamepad = controller.extendedGamepad {
            setupButton(gamepad.buttonA, name: "buttonA")
            setupButton(gamepad.buttonB, name: "buttonB")
            setupButton(gamepad.buttonX, name: "buttonX")
            setupButton(gamepad.buttonY, name: "buttonY")
            setupButton(gamepad.leftShoulder, name: "leftShoulder")
            setupButton(gamepad.rightShoulder, name: "rightShoulder")
            setupButton(gamepad.leftTrigger, name: "leftTrigger")
            setupButton(gamepad.rightTrigger, name: "rightTrigger")
            setupButton(gamepad.dpad.up, name: "dpadUp")
            setupButton(gamepad.dpad.down, name: "dpadDown")
            setupButton(gamepad.dpad.left, name: "dpadLeft")
            setupButton(gamepad.dpad.right, name: "dpadRight")
            setupButton(gamepad.buttonMenu, name: "buttonMenu")
            if let buttonOptions = gamepad.buttonOptions {
                setupButton(buttonOptions, name: "buttonOptions")
            }
        }
        // Handle basic gamepad
        else if let gamepad = controller.microGamepad {
            setupButton(gamepad.buttonA, name: "buttonA")
            setupButton(gamepad.buttonX, name: "buttonX")
        }
    }

    private func setupButton(_ button: GCControllerButtonInput, name: String) {
        button.valueChangedHandler = { [weak self] (_, _, pressed) in
            self?.handleButtonPress(buttonName: name, pressed: pressed)
        }
    }

    private func handleButtonPress(buttonName: String, pressed: Bool) {
        // If we're in recording mode, record the button
        if isRecording, pressed {
            onButtonRecorded?(buttonName)
            return
        }

        // Check if this button is mapped to any shortcut action
        guard let shortcutName = getMappedShortcut(for: buttonName) else { return }

        // Handle button press/release
        if pressed {
            handleActionDown(for: shortcutName)
        } else {
            handleActionUp(for: shortcutName)
        }
    }

    private func handleActionDown(for shortcutName: KeyboardShortcuts.Name) {
        switch shortcutName {
        case .toggleMuteShortcut:
            touchBarController?.handleToggleMode(mode: .toggle)
        case .muteOnlyShortcut:
            touchBarController?.handleToggleMode(mode: .muteOnly)
        case .unmuteOnlyShortcut:
            touchBarController?.handleToggleMode(mode: .unmuteOnly)
        case .pushToToggleShortcut:
            touchBarController?.pushToToggleDown()
        default:
            break
        }
    }

    private func handleActionUp(for shortcutName: KeyboardShortcuts.Name) {
        // Only push-to-toggle needs keyUp handling
        if shortcutName == .pushToToggleShortcut {
            touchBarController?.pushToToggleUp()
        }
    }

    // MARK: - Recording

    func startRecording(for shortcutName: KeyboardShortcuts.Name, onRecorded: @escaping (String) -> Void) {
        isRecording = true
        recordingFor = shortcutName
        onButtonRecorded = onRecorded
    }

    func stopRecording() {
        isRecording = false
        recordingFor = nil
        onButtonRecorded = nil
    }

    // MARK: - Button Mapping

    func setButtonMapping(buttonName: String, for shortcutName: KeyboardShortcuts.Name) {
        let key = getKey(for: shortcutName)
        defaults.set(buttonName, forKey: key)
        NotificationCenter.default.post(name: NSNotification.Name("ControllerMappingChanged"), object: nil)
    }

    func getButtonMapping(for shortcutName: KeyboardShortcuts.Name) -> String? {
        let key = getKey(for: shortcutName)
        return defaults.string(forKey: key)
    }

    func clearButtonMapping(for shortcutName: KeyboardShortcuts.Name) {
        let key = getKey(for: shortcutName)
        defaults.removeObject(forKey: key)
        NotificationCenter.default.post(name: NSNotification.Name("ControllerMappingChanged"), object: nil)
    }

    private func getMappedShortcut(for buttonName: String) -> KeyboardShortcuts.Name? {
        let shortcuts: [KeyboardShortcuts.Name] = [
            .toggleMuteShortcut,
            .muteOnlyShortcut,
            .unmuteOnlyShortcut,
            .pushToToggleShortcut
        ]

        for shortcut in shortcuts {
            if getButtonMapping(for: shortcut) == buttonName {
                return shortcut
            }
        }
        return nil
    }

    private func getKey(for shortcutName: KeyboardShortcuts.Name) -> String {
        return "controller_\(shortcutName.rawValue)"
    }

    // MARK: - Button Name Display

    static func getDisplayName(for buttonName: String) -> String {
        switch buttonName {
        case "buttonA": return "A"
        case "buttonB": return "B"
        case "buttonX": return "X"
        case "buttonY": return "Y"
        case "leftShoulder": return "L1"
        case "rightShoulder": return "R1"
        case "leftTrigger": return "L2"
        case "rightTrigger": return "R2"
        case "dpadUp": return "D-Pad ↑"
        case "dpadDown": return "D-Pad ↓"
        case "dpadLeft": return "D-Pad ←"
        case "dpadRight": return "D-Pad →"
        case "buttonMenu": return "Menu"
        case "buttonOptions": return "Options"
        default: return buttonName
        }
    }
}
