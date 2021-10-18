//
//  PostsCell.swift
//  ReduxVMSample
//
//  Created by ziryanov on 16.10.2020.
//

import UIKit
import DeclarativeTVC
import Kingfisher
import DateToolsSwift
import RxCocoa

final class PostCell: XibTableViewCell {
    @IBOutlet fileprivate var header: UIControl!
    @IBOutlet fileprivate var userAvatar: UIImageView!
    @IBOutlet fileprivate var userName: UILabel!
    @IBOutlet fileprivate var date: UILabel!
    
    @IBOutlet fileprivate var bodyText: UILabel!
    @IBOutlet fileprivate var bodyImage: UIImageView!
    @IBOutlet fileprivate var bodyImageHeight: NSLayoutConstraint!
    
    @IBOutlet fileprivate var likes: UIButton!
    @IBOutlet fileprivate var comments: UIButton!
    @IBOutlet fileprivate var reposts: UIButton!
    @IBOutlet fileprivate var views: UILabel!
    
    fileprivate var actions: PostCellActions!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        header.rx.controlEvent(.touchUpInside)
            .bind { [unowned self] _ in
                self.actions.userPressed.perform()
            }
            .disposed(by: rx.disposeBag)
        
        likes.rx.controlEvent(.touchUpInside)
            .bind { [unowned self] _ in
                self.actions.likePressed.perform()
            }
            .disposed(by: rx.disposeBag)

        comments.rx.controlEvent(.touchUpInside)
            .bind { [unowned self] _ in
                self.actions.commentPressed.perform()
            }
            .disposed(by: rx.disposeBag)

        reposts.rx.controlEvent(.touchUpInside)
            .bind { [unowned self] _ in
                self.actions.repostPressed.perform()
            }
            .disposed(by: rx.disposeBag)
    }
}

struct PostCellActions: Equatable, Hashable {
    let userPressed: Command
    let likePressed: Command
    let commentPressed: Command
    let repostPressed: Command
}

struct PostCellVM: CellModel, SelectableCellModel {
    let post: PostsContainer.Post
    let actions: PostCellActions
    let selectCommand: Command

    func apply(to cell: PostCell, containerView: UIScrollView) {
        cell.userAvatar.kf.setImage(with: try? post.userBasic.avatar?.asURL())
        cell.userName.text = post.userBasic.username
        cell.date.text = post.date.timeAgoSinceNow

        setBody(to: cell)

        cell.likes.setTitle(post.likesCount.shortText, for: .normal)
        cell.likes.isSelected = post.likedByMe

        cell.comments.setTitle(post.commentsCount.shortText, for: .normal)
        cell.comments.isSelected = post.commentedByMe
        cell.comments.isHidden = !post.canComment

        cell.reposts.setTitle(post.repostsCount.shortText, for: .normal)
        cell.reposts.isSelected = post.repostedByMe
        
        cell.views.text = post.viewsCount.shortText
        
        cell.actions = actions
    }
    
    private func setBody(to cell: PostCell) {
        cell.bodyText.text = post.bodyText
        if let bodyIamge = post.bodyImage {
            cell.bodyImage.kf.setImage(with: try? bodyIamge.image.asURL())
            cell.bodyImageHeight.constant = UIScreen.main.bounds.width * bodyIamge.ratio
        } else {
            cell.bodyImageHeight.constant = 0
        }
    }
}
