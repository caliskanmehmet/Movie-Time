//
//  UITableView+Extension.swift
//  MovieTime
//
//  Created by obss on 1.08.2021.
//

import Foundation
import UIKit

extension UITableView {
    func reloadDataThenPerform(_ closure: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(closure)
        self.reloadData()
        CATransaction.commit()
    }
}
