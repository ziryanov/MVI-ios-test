//
//  UserFollowersFollowerCell.swift
//  ReduxVMSample
//
//  Created by ziryanov on 11.11.2020.
//

import Foundation
import DeclarativeTVC
import Kingfisher
import RxCocoa

final class UserFollowersFollowerCell: StoryboardCollectionViewCell {
    @IBOutlet fileprivate var avatar: UIImageView!
    @IBOutlet fileprivate var name: UILabel!
}

struct UserFollowersFollowerCellVM: CellModel, SelectableCellModel {
    let user: UsersContainer.BasicUserInfo
    let selectCommand: Command
    
    func apply(to cell: UserFollowersFollowerCell, containerView: UIScrollView) {
        cell.avatar.kf.setImage(with: try? user.avatar?.asURL())
        cell.name.text = user.username
    }
}
