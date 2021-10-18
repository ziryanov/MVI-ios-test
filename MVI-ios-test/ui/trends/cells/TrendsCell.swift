//
//  TrendsCell.swift
//  MVI-ios-test
//
//  Created by ziryanov on 05.10.2021.
//

import Foundation
import DeclarativeTVC
import RxCocoa

final class TrendsCell: StoryboardTableViewCell {
    @IBOutlet fileprivate var position: UILabel!
    @IBOutlet fileprivate var name: UILabel!
    @IBOutlet fileprivate var change: UILabel!
}

struct TrendsCellVM: CellModel {
    let trend: TrendsFeature.State.Trend
    
    func innerHashValue() -> Int {
        trend.id.hash
    }
    
    func innerAnimationEquatableValue() -> Int {
        trend.id.hash
    }

    func apply(to cell: TrendsCell, containerView: UIScrollView) {
        cell.position.text = "\(trend.position)"
        cell.name.text = trend.name
        if let previos = trend.previous?.position {
            switch previos {
            case _ where previos < trend.position:
                cell.change.text = "↓\(trend.position - previos)"
                cell.change.textColor = .systemRed
            case _ where previos == trend.position:
                cell.change.text = "-"
                cell.change.textColor = .black
            default:
                cell.change.text = "↑\(previos - trend.position)"
                cell.change.textColor = .systemGreen
            }
        } else {
            cell.change.text = "new"
        }
    }
}
