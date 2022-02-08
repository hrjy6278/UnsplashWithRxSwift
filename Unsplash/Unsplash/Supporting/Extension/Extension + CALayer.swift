//
//  Extension + CLLayer.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/08.
//

import Foundation
import QuartzCore
import UIKit

extension CALayer {
    func configurationShadow(color: UIColor?,
                             radius: CGFloat? = nil,
                             opacity: Float? = nil,
                             offset: CGSize? = nil) {
        shadowColor = color?.cgColor
        radius.flatMap { unwrapRadius in shadowRadius = unwrapRadius }
        opacity.flatMap { unwrapOpacity in shadowOpacity = unwrapOpacity }
        offset.flatMap { unwrapOffset in shadowOffset = unwrapOffset }
    }
}
