//
//  HierarchySetupable.swift
//  Unsplash
//
//  Created by KimJaeYoun on 2021/12/19.
//

import Foundation

protocol HierarchySetupable {
    func setupViewHierarchy()
    func setupLayout()
    
    func setupView()
}

extension HierarchySetupable {
    func setupView() {
        setupViewHierarchy()
        setupLayout()
    }
}
