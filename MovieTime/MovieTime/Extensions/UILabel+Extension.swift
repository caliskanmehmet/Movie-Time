//
//  UILabel+Extension.swift
//  MovieTime
//
//  Created by obss on 31.07.2021.
//

import Foundation
import UIKit

extension UILabel {

    func addTrailing(image: UIImage, text: String) {
        let attachment = NSTextAttachment()
        attachment.image = image

        let attachmentString = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: text, attributes: [:])

        string.append(attachmentString)
        self.attributedText = string
    }

    func addLeading(image: UIImage, text: String, offset: Double = -5.0) {
        let offsetY = offset

        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0.0,
                                   y: CGFloat(offsetY),
                                   width: attachment.image?.size.width ?? 0,
                                   height: attachment.image?.size.height ?? 0)

        let attachmentString = NSAttributedString(attachment: attachment)
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(attachmentString)

        let string = NSMutableAttributedString(string: text, attributes: [:])
        mutableAttributedString.append(string)
        self.attributedText = mutableAttributedString
    }
}
