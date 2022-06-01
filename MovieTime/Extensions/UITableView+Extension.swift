//
//  UITableView+Extension.swift
//  MovieTime
//
//  Created by Mehmet Caliskan on 1.08.2021.
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
