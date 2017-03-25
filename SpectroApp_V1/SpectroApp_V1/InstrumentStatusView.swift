//
//  InstrumentAlertView.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

let _UIBlue = UIColor(21, 126, 251)
let goodStatusGreen =  UIColor(52, 133, 88)

enum InstrumentStatus: String, CustomStringConvertible {
    case good = "Connected"
    case warning = "Not connected"
    case busy
    case unknown
    func show(with view: InstrumentStatusView) {
        switch self {
        case .good: view.showGoodStatus()
        case .warning: view.showWarningStatus()
        case .busy: view.showBusy()
        case .unknown: view.backgroundView.backgroundColor = .clear
        }
    }
    var color: UIColor {
        switch self {
        case .good: return goodStatusGreen
        case .busy, .unknown: return .clear
        case.warning: return .red
        }
    }
    
    var description: String {
        switch self {
        default:
            return self.rawValue.capitalized
        }
    }
}

class InstrumentStatusView: UIView, CBInstrumentCentralManagerReporter {
    
    @IBOutlet private weak var checkMark: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var messageLabel: UILabel?
    @IBOutlet weak var backgroundView: UIView!
    
    var status: InstrumentStatus = .unknown {
        didSet {
            guard oldValue != status else { return }
            status.show(with: self)
        }
    }
    
    var message: String? {
        didSet {
            guard let label = messageLabel else {
                return
            }
            if label.isHidden {
                UIView.animate(withDuration: 0.15, animations: {
                    self.messageLabel?.isHidden = false
                    label.text = self.message ?? self.status.description
                })
            } else {
                UIView.animate(withDuration: 0.15, animations: {
                    label.text = self.message ?? self.status.description
                })
            }
            
        }
    }
    
    var isGrayedOut: Bool = false {
        didSet {
            guard isGrayedOut != oldValue else {
                return
            }
            print("did set isGrayedOut to: \(isGrayedOut)")
            if isGrayedOut {
                if self.backgroundView.backgroundColor != .clear {
                    UIView.animate(withDuration: 0.15, animations: {
                        self.backgroundView.backgroundColor = .gray
                    })
                }
                self.button.isUserInteractionEnabled = false
            } else {
                UIView.animate(withDuration: 0.15, animations: {
                    self.backgroundView.backgroundColor = self.status.color
                })
                self.button.isUserInteractionEnabled = true
            }
        }
    }
    
    func setup(isFirstTime: Bool = true) {
        print("setting up instrument alert view")
        if backgroundView == nil {
            print("setting background view to be the alert view")
            backgroundView = self
        }
        backgroundView.layer.cornerRadius = backgroundView.frame.width / 2
        backgroundView.backgroundColor = .clear
        checkMark.isHidden = true
        label.isHidden = true
        activityIndicator.hidesWhenStopped = true
        messageLabel?.isHidden = true
        activityIndicator.stopAnimating()
        
        if isFirstTime {
            status = .busy
        }
    }
    
    fileprivate func showGoodStatus() {
        self.activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.15, animations: {
            if self.isGrayedOut { self.backgroundView.backgroundColor = .gray }
            else { self.backgroundView.backgroundColor = _UIBlue }
            self.checkMark.isHidden = false
            self.label.isHidden = true
        })
    }
    
    fileprivate func showWarningStatus() {
        self.activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.15, animations: {
            if self.isGrayedOut { self.backgroundView.backgroundColor = .gray }
            else { self.backgroundView.backgroundColor = .red }
            self.checkMark.isHidden = true
            self.label.isHidden = false
        })
    }
    
    fileprivate func showBusy() {
        UIView.animate(withDuration: 0.15, animations: {
            self.backgroundView.backgroundColor = .clear
            self.checkMark.isHidden = true
            self.label.isHidden = true
        })
        self.activityIndicator.startAnimating()
    }
    
    func display(_ status: InstrumentStatus, message: String?) {
        DispatchQueue.main.async {
            self.status = status
            self.message = message
        }
    }
    
}

extension UIColor {
    convenience init(_ r: Int, _ g: Int, _ b: Int, _ alpha: Float = 1) {
        let red = Float(r) / Float(255)
        let green = Float(g) / Float(255)
        let blue = Float(b) / Float(255)
        self.init(colorLiteralRed: red, green: green, blue: blue, alpha: alpha)
    }
}
