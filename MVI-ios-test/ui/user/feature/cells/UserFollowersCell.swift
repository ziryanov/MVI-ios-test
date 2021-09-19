//
//  UserFollowersCell.swift
//  ReduxVMSample
//
//  Created by ziryanov on 11.11.2020.
//

import Foundation
import DeclarativeTVC
import RxCocoa

final class UserFollowersCell: StoryboardTableViewCell {
    @IBOutlet fileprivate var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.decelerationRate = .fast
    }
}

struct UserFollowersCellVM: CellModel {
    let users: [UsersContainer.BasicUserInfo]
    let userPressed: CommandWith<UsersContainer.BasicUserInfo>
    
    private let ds = CollectionDS()
    func apply(to cell: UserFollowersCell, containerView: UIScrollView) {
        let rows = users.map { user in
            UserFollowersFollowerCellVM(user: user,
                                        selectCommand: Command() { [userPressed] in userPressed.perform(with: user) })
        }
        ds.set(collectionView: cell.collectionView, items: rows, animated: false)
    }
}

