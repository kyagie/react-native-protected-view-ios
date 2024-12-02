import Foundation
import React
import UIKit

@objc(RNProtectedViewIos)
class ProtectedViewIos: RCTViewManager {
    override func view() -> UIView! {
        return ProtectedNativeView()
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
}

class ProtectedNativeView: UIView {
    private var textField: UITextField
    private var secureCanvas: UIView?
    private var contentView: UIView
    private var options: ProtectionOptions = .all
    private var cancellables = Set<NSKeyValueObservation>()
    
    override init(frame: CGRect) {
        textField = UITextField()
        contentView = UIView()
        super.init(frame: frame)
        
        setupView()
        setupProtection()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        textField.isSecureTextEntry = true
        textField.isUserInteractionEnabled = false
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupProtection() {
        // Handle inactivity protection
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppStateChange(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppStateChange(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        // Handle screen capture protection
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenCaptureChange),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
        
        // Setup secure canvas
        DispatchQueue.main.async { [weak self] in
            if let secureCanvas = self?.textField.canvasView {
                self?.secureCanvas = secureCanvas
                self?.replaceContentWithSecureCanvas()
            }
        }
    }
    
    @objc private func handleAppStateChange(_ notification: Notification) {
        guard options.contains(.inactivity) else { return }
        contentView.isHidden = notification.name == UIApplication.willResignActiveNotification
    }
    
    @objc private func handleScreenCaptureChange() {
        guard options.contains(.screenSharing) else { return }
        contentView.isHidden = UIScreen.main.isCaptured
    }
    
    private func replaceContentWithSecureCanvas() {
        guard let secureCanvas = secureCanvas else { return }
        
        // Move all subviews to secure canvas
        for subview in contentView.subviews {
            subview.removeFromSuperview()
            secureCanvas.addSubview(subview)
            subview.frame = secureCanvas.bounds
            subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        // Replace content view with secure canvas
        contentView.removeFromSuperview()
        addSubview(secureCanvas)
        secureCanvas.frame = bounds
        secureCanvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @objc func setOptions(_ newOptions: NSNumber) {
        options = ProtectionOptions(rawValue: newOptions.intValue)
    }
}