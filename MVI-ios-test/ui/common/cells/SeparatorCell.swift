//
//  SeparatorCell.swift
//  MVI-ios-test
//
//  Created by ziryanov on 05.10.2021.
//

import UIKit
import DeclarativeTVC

class SeparatorCell: XibTableViewCell {
    @IBOutlet fileprivate var line: UIView!
}

struct SeparatorCellVM: CellModel {
    let color: UIColor
    
    func apply(to cell: SeparatorCell, containerView: UIScrollView) {
        cell.line.backgroundColor = color
    }
}
