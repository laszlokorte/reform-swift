//
//  Vec2d.swift
//  ReformMath
//
//  Created by Laszlo Korte on 12.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import XCTest
@testable import ReformMath

final class Vec2dTests: XCTestCase {

    let PRECISION = 0.0001

    func testZeroInit() {
        let vec = Vec2d()

        XCTAssertEqualWithAccuracy(vec.x, 0, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(vec.y, 0, accuracy: PRECISION)
    }

    func testCustomInit() {
        let vec = Vec2d(x: 42, y: 23)

        XCTAssertEqualWithAccuracy(vec.x, 42, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(vec.y, 23, accuracy: PRECISION)
    }

    func testPolarInit() {
        let right = Vec2d(radius: 2, angle: Angle(degree: 0))
        XCTAssertEqualWithAccuracy(right.x, 2, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(right.y, 0, accuracy: PRECISION)


        let up = Vec2d(radius: 2, angle: Angle(degree: 90))
        XCTAssertEqualWithAccuracy(up.x, 0, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(up.y, 2, accuracy: PRECISION)


        let left = Vec2d(radius: 2, angle: Angle(degree: 180))
        XCTAssertEqualWithAccuracy(left.x, -2, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(left.y, 0, accuracy: PRECISION)


        let down = Vec2d(radius: 2, angle: Angle(degree: 270))
        XCTAssertEqualWithAccuracy(down.x, 0, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(down.y, -2, accuracy: PRECISION)
    }

    func testEquality() {
        let a = Vec2d(x: 42, y: 23)
        let b = Vec2d(x: 42, y: 23)
        let c = Vec2d(x: 72, y: 12)

        XCTAssert(a == b)
        XCTAssert(b == a)


        XCTAssert(b != c)
        XCTAssert(c != b)
        XCTAssert(a != c)
        XCTAssert(c != a)
    }

    func testLength() {
        let left = Vec2d(x: -10, y: 0)
        let diagonal = Vec2d(x: -10, y: 10)
        let up = Vec2d(x: 0, y: 10)

        XCTAssertEqualWithAccuracy(left.length, 10, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(diagonal.length, sqrt(200), accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(up.length, 10, accuracy: PRECISION)
    }

    func testLength2() {
        let left = Vec2d(x: -10, y: 0)
        let diagonal = Vec2d(x: -10, y: 10)
        let up = Vec2d(x: 0, y: 10)

        XCTAssertEqualWithAccuracy(left.length2, 100, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(diagonal.length2, 200, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(up.length2, 100, accuracy: PRECISION)
    }

    func testLength²() {
        let left = Vec2d(x: -10, y: 0)
        let diagonal = Vec2d(x: -10, y: 10)
        let up = Vec2d(x: 0, y: 10)

        XCTAssertEqualWithAccuracy(left.length², 100, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(diagonal.length², 200, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(up.length², 100, accuracy: PRECISION)
    }

}
