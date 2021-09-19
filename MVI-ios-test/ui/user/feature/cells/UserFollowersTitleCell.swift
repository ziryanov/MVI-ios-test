//
//  UserFollowersTitleCell.swift
//  ReduxVMSample
//
//  Created by ziryanov on 11.11.2020.
//

import Foundation
import DeclarativeTVC
import RxCocoa

final class UserFollowersTitleCell: StoryboardTableViewCell {
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var followerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "Followers"
    }
}

struct UserFollowersTitleCellVM: CellModel, SelectableCellModel {
    let followersCount: Int
    let selectCommand: Command
    
    private let ds = CollectionDS()
    func apply(to cell: UserFollowersTitleCell, containerView: UIScrollView) {
        cell.followerLabel.text = "\(followersCount)"
    }
}
