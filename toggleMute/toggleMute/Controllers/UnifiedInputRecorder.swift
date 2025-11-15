// Author: Sascha Petrik

import Cocoa
import KeyboardShortcuts

/// A recorder view that can accept both keyboard shortcuts AND game controller button input
class UnifiedInputRecorder: NSView {

    private let shortcutName: KeyboardShortcuts.Name
    private let keyboardRecorder: KeyboardShortcuts.RecorderCocoa
    private var isListeningForController = false

    init(for shortcutName: KeyboardShortcuts.Name) {
        self.shortcutName = shortcutName
        self.keyboardRecorder = KeyboardShortcuts.RecorderCocoa(for: shortcutName)
        super.init(frame: .zero)
        setupUI()
        startListeningForControllerInput()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Add the keyboard recorder
        keyboardRecorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(keyboardRecorder)

        NSLayoutConstraint.activate([
            keyboardRecorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            keyboardRecorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            keyboardRecorder.topAnchor.constraint(equalTo: topAnchor),
            keyboardRecorder.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Check if there's a controller mapping and update display
        updateDisplayForControllerMapping()
    }

    private func startListeningForControllerInput() {
        // Monitor when keyboard recorder is actively recording
        // When user clicks to record, listen for BOTH keyboard AND controller input
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerMappingChanged),
            name: NSNotification.Name("ControllerMappingChanged"),
            object: nil
        )

        // Start continuous controller monitoring
        startControllerMonitoring()
    }

    private func startControllerMonitoring() {
        // When GameController input is detected while keyboard recorder is active,
        // we'll capture it
        GameControllerManager.shared.startRecording(for: shortcutName) { [weak self] buttonName in
            guard let self = self else { return }
            // User pressed a controller button - save it and clear keyboard shortcut
            KeyboardShortcuts.setShortcut(nil, for: self.shortcutName)
            GameControllerManager.shared.setButtonMapping(buttonName: buttonName, for: self.shortcutName)
            self.updateDisplayForControllerMapping()
        }
    }

    private func updateDisplayForControllerMapping() {
        // If there's a controller button mapped, show it with a gamepad emoji prefix
        if let controllerButton = GameControllerManager.shared.getButtonMapping(for: shortcutName) {
            let displayName = GameControllerManager.getDisplayName(for: controllerButton)
            // Override the keyboard recorder's display
            DispatchQueue.main.async {
                // Find the button in the keyboard recorder and update its title
                if let button = self.findRecorderButton(in: self.keyboardRecorder) {
                    button.title = "🎮 \(displayName)"
                }
            }
        }
    }

    private func findRecorderButton(in view: NSView) -> NSButton? {
        if let button = view as? NSButton {
            return button
        }
        for subview in view.subviews {
            if let button = findRecorderButton(in: subview) {
                return button
            }
        }
        return nil
    }

    @objc private func controllerMappingChanged() {
        updateDisplayForControllerMapping()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        GameControllerManager.shared.stopRecording()
    }
}
