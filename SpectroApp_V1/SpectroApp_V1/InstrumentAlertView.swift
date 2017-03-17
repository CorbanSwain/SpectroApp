//
//  InstrumentAlertView.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/16/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

enum InstrumentStatus {
    case good
    case warning
    case busy
    func show(with view: InstrumentAlertView) {
        switch self {
        case .good: view.showGoodStatus()
        case .warning: view.showWarningStatus()
        case .busy: view.showBusy()
        }
    }
    var color: UIColor {
        switch self {
        case .good: return InstrumentAlertView._CNSBlue
        case .busy: return .clear
        case.warning: return .red
        }
    }
}

class InstrumentAlertView: UIView, InstrumentBluetoothManagerReporter {
    
    @IBOutlet private weak var checkMark: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    fileprivate static let _CNSBlue = UIColor(21, 126, 251)
    
    var status: InstrumentStatus = .busy {
        didSet {
            guard oldValue != status else { return }
            status.show(with: self)
        }
    }
        
    func setup() {
        layer.cornerRadius = frame.width / 2
        backgroundColor = .clear
        checkMark.isHidden = true
        label.isHidden = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    fileprivate func showGoodStatus() {
        self.activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.5, animations: {
            if self.isGrayedOut { self.backgroundColor = .gray }
            else { self.backgroundColor = InstrumentAlertView._CNSBlue }
            self.checkMark.isHidden = false
            self.label.isHidden = true
        })
    }
    
    fileprivate func showWarningStatus() {
        self.activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.5, animations: {
            if self.isGrayedOut { self.backgroundColor = .gray }
            else { self.backgroundColor = .red }
            self.checkMark.isHidden = true
            self.label.isHidden = false
        })
    }
    
    fileprivate func showBusy() {
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = .clear
            self.checkMark.isHidden = true
            self.label.isHidden = true
        })
        self.activityIndicator.startAnimating()
    }
    
    func setStatusTo(_ status: InstrumentStatus) {
        DispatchQueue.main.async {
            self.status = status
        }
    }
    
    var isGrayedOut: Bool = false {
        didSet {
            print("did set isGrayedOut to: \(isGrayedOut)")
            if isGrayedOut {
                self.backgroundColor = .gray
                self.button.isUserInteractionEnabled = false
            } else {
                self.backgroundColor = status.color
                self.button.isUserInteractionEnabled = true
            }
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
