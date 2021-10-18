//
//  TrendsVC.swift
//  MVI-ios-test
//
//  Created by ziryanov on 05.10.2021.
//

import UIKit
import DeclarativeTVC

final class TrendsVC: TVC<TrendsVCModule.Props, TrendsVCModule.Actions, Void> {
    override class var storyboardName: String {
        return "Trends"
    }
    
    let animation = Animations(deleteSectionsAnimation: .automatic, insertSectionsAnimation: .automatic, reloadSectionsAnimation: .automatic, deleteRowsAnimation: .automatic, insertRowsAnimation: .automatic, reloadRowsAnimation: .automatic)
    override func render(props: TrendsVCModule.Props) {
        set(model: props.tableModel, animations: animation, completion: { [weak self] in
            self?.reloadVisibleCells()
        })
    }
}
