//
//  Extension + UIFont.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/02/04.
//

import UIKit

extension UIFont {
    enum FontType: CustomStringConvertible {
        case SDGothichRegular
        case SDGothichBold
        
        var description: String {
            switch self {
            case .SDGothichRegular:
                return "AppleSDGothicNeo-Regular"
            case .SDGothichBold:
                return "AppleSDGothicNeo-Bold"
            }
        }
    }
    
    static func generateFont(font: FontType, size: CGFloat) -> UIFont? {
        return UIFont(name: String(describing: font), size: size)
    }
}
