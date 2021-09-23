//
//  LoadingCell.swift
//  ReduxVMSample
//
//  Created by ziryanov on 21.10.2020.
//

import UIKit
import DeclarativeTVC

class LoadingCell: XibTableViewCell {
    @IBOutlet private var loading: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        loading.startAnimating()
    }
}

struct LoadingCellVM: CellModel {
    func apply(to cell: LoadingCell, containerView: UIScrollView) {
        
    }
}
