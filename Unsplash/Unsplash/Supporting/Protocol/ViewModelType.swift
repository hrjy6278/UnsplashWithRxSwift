//
//  ViewModelType.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2022/04/01.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func bind(input: Input) -> Output
}
