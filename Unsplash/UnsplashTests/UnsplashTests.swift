//
//  UnsplashTests.swift
//  UnsplashTests
//
//  Created by KimJaeYoun on 2021/12/17.
//

import XCTest
@testable import Unsplash

class UnsplashTests: XCTestCase {
    let sut = KeyChainStore()
    
    override func tearDown() {
        super.tearDown()
        self.sut.removeAll()
    }
    
    func test_키체인에_패스워드를_넣으면_저장이된다() {
        //given
        let password = "1234"
        
        //when
        try! sut.setValue(password, for: "Unsplash")
        
        //then
        let keychainPassword = try! sut.getValue(for: "Unsplash")
        
        XCTAssertEqual(password, keychainPassword)
    }
    
    func test_키체인에_패스워드를_변경하면_변경이된다() {
        //given
        let firstPassword = "1234"
        let secondPassword = "5678"
        
        //when
        try! sut.setValue(firstPassword, for: "UnsplashPassword")
        try! sut.setValue(secondPassword, for: "UnsplashPassword")
        
        //then
        let keychainPassword = try! sut.getValue(for: "UnsplashPassword")
        XCTAssertEqual(secondPassword, keychainPassword)
    }
    
    func test_키체인의_아이템이_정상적으로_삭제된다() {
        //given
        let password = "1234"
        
        //when
        try! sut.setValue(password, for: "UnsplashPassword")
        sut.removeValue(for: "UnsplashPassword")
        
        //then
        XCTAssertNil(try sut.getValue(for: "UnsplashPassword"))
    }
    
    func test_키체인의_아이템이_전부삭제된다() {
        //given
        let firstPassword = "1234"
        let secondPassword = "5678"
        let thirdPassword = "0000"
        
        //when
        try! sut.setValue(firstPassword, for: "firstPassword")
        try! sut.setValue(secondPassword, for: "secondPassword")
        try! sut.setValue(thirdPassword, for: "thirdPassword")
        
        sut.removeAll()
        
        //then
        XCTAssertNil(try sut.getValue(for: "firstPassword"))
        XCTAssertNil(try sut.getValue(for: "secondPassword"))
        XCTAssertNil(try sut.getValue(for: "thirdPassword"))
    }
    
}
