//
//  Declarative.swift
//  MVI-ios-test
//
//  Created by ziryanov on 05.10.2021.
//

import Foundation
import DeclarativeTVC

extension DeclarativeTVC {
    func reloadVisibleCells() {
        for cell in self.tableView.visibleCells {
            guard let indexPath = self.tableView.indexPath(for: cell), let vm = model?.sections[indexPath.section].rows[indexPath.row] else { continue }
            vm.apply(to: cell, containerView: self.tableView)
        }
    }
}
