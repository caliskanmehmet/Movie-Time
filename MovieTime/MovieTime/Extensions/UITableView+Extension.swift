//
//  UITableView+Extension.swift
//  MovieTime
//
//  Created by obss on 1.08.2021.
//

import Foundation
import UIKit

extension UITableView {
    /*func reloadData(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() }) {_ in
            completion()
        }
    }*/

    func reloadDataThenPerform(_ closure: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(closure)
        self.reloadData()
        CATransaction.commit()
    }
}
