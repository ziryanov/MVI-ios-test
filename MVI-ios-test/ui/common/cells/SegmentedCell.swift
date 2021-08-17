//
//  SegmentedCell.swift
//  ReduxVMSample
//
//  Created by ziryanov on 21.10.2020.
//

import UIKit
import DeclarativeTVC
import RxCocoa

class SegmentedCell: XibTableViewCell {

    @IBOutlet fileprivate var segment: UISegmentedControl!
    fileprivate var changeSegment: CommandWith<Int>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        segment.rx.controlEvent(.valueChanged)
            .bind { [unowned self] _ in
                if let index = self.segment?.selectedSegmentIndex {
                    self.changeSegment?.perform(with: index)
                }
            }
            .disposed(by: rx.disposeBag)
    }
}

struct SegmentedCellVM: CellModel {
    let segments: [String]
    let selectedIndex: Int
    let changeSegment: CommandWith<Int>

    func apply(to cell: SegmentedCell, containerView: UIScrollView) {
        for (i, name) in segments.enumerated() where cell.segment.titleForSegment(at: i) != name {
            cell.segment.setTitle(name, forSegmentAt: i)
        }
        cell.segment.selectedSegmentIndex = selectedIndex
        cell.changeSegment = changeSegment
    }    
}
