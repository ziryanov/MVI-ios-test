//
//  ButtonWithActivity.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import UIKit
import LGButton

final class GreenButton: LGButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleFontSize = 16
        bgColor = UIColor(red: 0, green: 139.0 / 256, blue: 0, alpha: 1)
        borderColor = .darkGray
        borderWidth = 3
        cornerRadius = 8
    }
}
