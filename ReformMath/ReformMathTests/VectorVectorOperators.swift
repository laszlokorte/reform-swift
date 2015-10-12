//
//  VectorVectorOperators.swift
//  ReformMath
//
//  Created by Laszlo Korte on 12.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import XCTest
@testable import ReformMath

final class VectorVectorOperatorTest : XCTestCase {

    let PRECISION = 0.0001

    func testAddition() {
        let a = Vec2d(x: 3, y: 7)
        let b = Vec2d(x: 11, y: -6)

        let sumA = a + b
        let sumB = b + a

        XCTAssertEqualWithAccuracy(sumA.x, sumB.x, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(sumA.y, sumB.y, accuracy: PRECISION)

        XCTAssertEqualWithAccuracy(sumA.x, 14, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(sumA.y, 1, accuracy: PRECISION)
    }

    func testAdditionZero() {
        let a = Vec2d()
        let b = Vec2d(x: 11, y: -6)

        let sumA = a + b
        let sumB = b + a

        XCTAssertEqualWithAccuracy(sumA.x, sumB.x, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(sumA.y, sumB.y, accuracy: PRECISION)

        XCTAssertEqualWithAccuracy(sumA.x, b.x, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(sumA.y, b.y, accuracy: PRECISION)
    }

    func testSubtraction() {
        let a = Vec2d(x: 3, y: 7)
        let b = Vec2d(x: 11, y: -6)

        let differenceA = a - b

        XCTAssertEqualWithAccuracy(differenceA.x, -8, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(differenceA.y, 13, accuracy: PRECISION)
    }


    func testSubtractionZero() {
        let a = Vec2d(x: 3, y: 7)
        let b = Vec2d()

        let differenceA = a - b

        XCTAssertEqualWithAccuracy(differenceA.x, 3, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(differenceA.y, 7, accuracy: PRECISION)
    }

    func testNegation() {
        let vec = Vec2d(x: 3, y: 7)

        let negation = -vec

        XCTAssertEqualWithAccuracy(negation.x, -3, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(negation.y, -7, accuracy: PRECISION)
    }


    func testNegationZero() {
        let vec = Vec2d()

        let negation = -vec

        XCTAssertEqualWithAccuracy(negation.x, vec.x, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(negation.y, vec.y, accuracy: PRECISION)
    }
}