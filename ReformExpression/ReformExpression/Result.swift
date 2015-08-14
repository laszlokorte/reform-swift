//
//  Result.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 10.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public enum Result<T, E> {
    case Success(T)
    case Fail(E)
}
