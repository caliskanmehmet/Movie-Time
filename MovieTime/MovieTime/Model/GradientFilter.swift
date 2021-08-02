//
//  GradientFilter.swift
//  MovieTime
//
//  Created by obss on 2.08.2021.
//

import Foundation
import Kingfisher
import UIKit

struct GradientFilter: CIImageProcessor {

    let startColor: UIColor
    let endColor: UIColor
    
    let startVector: CIVector
    let endVector: CIVector
    
    var identifier: String {
        return "com.domain.CILinearGradient_#{startcolor}_#{endcolor}_#{startvector}_#{endvector}"
    }

    var filter: Filter {
        return Filter { input in
            guard let colorFilter = CIFilter(name: "CILinearGradient") else { return nil }
            
            let startColor = CIColor(cgColor: self.startColor.cgColor)
            let endColor = CIColor(cgColor: self.endColor.cgColor)
            
            colorFilter.setValue(self.startVector, forKey: "inputPoint0")
            colorFilter.setValue(self.endVector, forKey: "inputPoint1")
            colorFilter.setValue(startColor, forKey: "inputColor0")
            colorFilter.setValue(endColor, forKey: "inputColor1")
            
            let colorImage = colorFilter.outputImage
            let filter = CIFilter(name: "CISourceOverCompositing")!
            filter.setValue(colorImage, forKey: kCIInputImageKey)
            filter.setValue(input, forKey: kCIInputBackgroundImageKey)
            return filter.outputImage?.cropped(to: input.extent)
        }
    }
}
