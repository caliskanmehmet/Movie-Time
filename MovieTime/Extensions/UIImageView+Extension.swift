//
//  UIImageView+Extension.swift
//  MovieTime
//
//  Created by obss on 18.08.2021.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    func setImage(urlString: String?, processor: ImageProcessor) {
        self.showAnimatedSkeleton()

        let options: KingfisherOptionsInfo = [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage,
            .cacheSerializer(FormatIndicatedCacheSerializer.png)
        ]

        if let safeUrl = urlString {
            self.kf.setImage(with: URL(string: safeUrl), options: options) { [weak self] response in
                switch response {
                case .success(_):
                    self?.hideSkeleton()
                case .failure(let error):
                    if !error.isTaskCancelled && !error.isNotCurrentTask {
                        self?.hideSkeleton()
                        self?.image = UIImage(named: "placeholder")
                    }
                }
            }
        } else {
            self.hideSkeleton()
            self.image = UIImage(named: "placeholder")
        }
    }
}
