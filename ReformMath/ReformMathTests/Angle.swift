//
//  Angle.swift
//  ReformMath
//
//  Created by Laszlo Korte on 12.10.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import XCTest
@testable import ReformMath

final class AngleTests: XCTestCase {

    let PRECISION = 0.0001

    func testZeroInit() {
        let angle = Angle()

        XCTAssertEqualWithAccuracy(angle.degree, 0, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(angle.radians, 0, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(angle.percent, 0, accuracy: PRECISION)
    }

    func testInitRadians() {
        let angle = Angle(radians: Scalar.PI)

        XCTAssertEqualWithAccuracy(angle.degree, 180, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(angle.radians, Scalar.PI, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(angle.percent, 50, accuracy: PRECISION)
    }

    func testInitDegree() {
        let angle = Angle(degree: 90)

        XCTAssertEqualWithAccuracy(angle.degree, 90, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(angle.radians, Scalar.PI/2, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(angle.percent, 25, accuracy: PRECISION)
    }

    func testInitPercent() {
        let angle = Angle(percent: 75)

        XCTAssertEqualWithAccuracy(angle.degree, 270, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(angle.radians, Scalar.PI*3/2, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(angle.percent, 75, accuracy: PRECISION)
    }

    func testSin() {
        let zero = Angle(percent: 0)
        let pi = Angle(percent: 50)
        let piHalf = Angle(percent: 25)

        XCTAssertEqualWithAccuracy(zero.sin, 0, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(pi.sin, 0, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(piHalf.sin, 1, accuracy: PRECISION)
    }

    func testCos() {
        let zero = Angle(percent: 0)
        let pi = Angle(percent: 50)
        let piHalf = Angle(percent: 25)

        XCTAssertEqualWithAccuracy(zero.cos, 1, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(pi.cos, -1, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(piHalf.cos, 0, accuracy: PRECISION)
    }

    func testTan() {
        let zero = Angle(percent: 0)
        let pi = Angle(percent: 50)

        XCTAssertEqualWithAccuracy(zero.tan, 0, accuracy: PRECISION)
        XCTAssertEqualWithAccuracy(pi.tan, 0, accuracy: PRECISION)
    }



    func testEquality() {
        let a = Angle(degree: 30)
        let b = Angle(degree: 30)
        let c = Angle(degree: 330)

        XCTAssert(a == b)
        XCTAssert(b == a)

        XCTAssert(a != c)
        XCTAssert(c != a)
        XCTAssert(b != c)
        XCTAssert(c != b)
    }

    func testComparable() {
        let a = Angle(degree: 30)
        let b = Angle(degree: 30)
        let c = Angle(degree: 330)
        let d = Angle(degree: -50)

        XCTAssertFalse(a < b)
        XCTAssertFalse(b < a)
        XCTAssert(d < a)
        XCTAssert(d < b)
        XCTAssert(d < c)

        XCTAssert(a < c)
        XCTAssertFalse(c < a)
        XCTAssert(b < c)
        XCTAssertFalse(c < b)
    }

}
