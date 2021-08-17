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
}

struct PostCellVM: CellModel, SelectableCellModel {
    let post: PostsContainer.Post
    
    let userPressed: Command
    let likePressed: Command
    let commentPressed: Command
    let repostPressed: Command
    
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
        
        cell.header.rx.controlEvent(.touchUpInside)
            .bind { [userPressed] _ in
                userPressed.perform()
            }
            .disposed(by: cell.rx.disposeBag(tag: "header"))
        
        cell.likes.rx.controlEvent(.touchUpInside)
            .bind { [likePressed] _ in
                likePressed.perform()
            }
            .disposed(by: cell.rx.disposeBag(tag: "likes"))
//
//        cell.comments.rx.controlEvent(.touchUpInside)
//            .bind { [commentPressed] _ in
//                commentPressed.perform()
//            }
//            .disposed(by: cell.rx.disposeBag(tag: "comments"))
//
//        cell.reposts.rx.controlEvent(.touchUpInside)
//            .bind { [repostPressed] _ in
//                repostPressed.perform()
//            }
//            .disposed(by: cell.rx.disposeBag(tag: "repost"))
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
