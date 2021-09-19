//
//  UserHeaderCell.swift
//  ReduxVMSample
//
//  Created by ziryanov on 09.11.2020.
//

import UIKit
import DeclarativeTVC
import Kingfisher
import RxCocoa

final class UserHeaderCell: StoryboardTableViewCell {
    @IBOutlet fileprivate var useAvatar: UIImageView!
    @IBOutlet fileprivate var userName: UILabel!
    @IBOutlet fileprivate var addInfo: UILabel!
    
    @IBOutlet fileprivate var followButton: UIButton!
    @IBOutlet fileprivate var messageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        followButton.setTitle("Follow", for: .normal)
        messageButton.setTitle("Send message", for: .normal)
    }
}

struct UserHeaderCellVM: CellModel {
    let userBasic: UsersContainer.BasicUserInfo
    let fullUser: UsersContainer.User?
    
    let followPressed: Command
    let messagePressed: Command

    func apply(to cell: UserHeaderCell, containerView: UIScrollView) {
        cell.useAvatar.kf.setImage(with: try? userBasic.avatar?.asURL())
        cell.userName.text = userBasic.username
        if let fullUser = fullUser {
            cell.addInfo.text = fullUser.additionalIndo
        }
        cell.addInfo.isHidden = fullUser == nil
        cell.followButton.isHidden = fullUser == nil

        cell.followButton.rx.controlEvent(.touchUpInside)
            .bind { [followPressed] _ in
                followPressed.perform()
            }
            .disposed(by: cell.rx.disposeBag(tag: "follow"))

        cell.messageButton.rx.controlEvent(.touchUpInside)
            .bind { [messagePressed] _ in
                messagePressed.perform()
            }
            .disposed(by: cell.rx.disposeBag(tag: "message"))
    }
}

