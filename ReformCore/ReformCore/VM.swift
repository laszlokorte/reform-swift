//
//  VM.swift
//  ReformCore
//
//  Created by Laszlo Korte on 09.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


typealias VMInstruction = Int
typealias VMProgramm = [VMInstruction]

enum VMError : ErrorProtocol {
    case invalidInstruction
}

class VM {
    private var memory = [Int]()
    private var stack = [Int]()
    private var halt = true
    private var programCounter: Int = 0
    private var nextPC : Int? = nil

    func run(_ program: VMProgramm) throws {
        programCounter = 0
        halt = false
        while !halt && programCounter < program.count {
            guard let instruction = VMOperatation(rawValue: program[programCounter]) else {
                throw VMError.invalidInstruction
            }
            instruction.executeOn(self)
            programCounter = nextPC ?? programCounter + 1
        }
    }
}

enum VMOperatation : VMInstruction {
    case pushImmediate
    case load
    case store
    case pop

    case mulInt
    case addInt
    case subInt
    case divInt

    case mulFloat
    case addFloat
    case subFloat
    case divFloat

    case sin
    case cos
    case tan
    case arcSin
    case arcCos
    case arcTan

    case sqrt

    case lessThan
    case equal

    case intToFloat
    case floatToInt

    case halt

    private func executeOn(_ vm: VM) {
        switch self {
        case pushImmediate:

            vm.nextPC = vm.programCounter + 1
        case load:
            vm.nextPC = vm.programCounter + 1
        case store:
            vm.nextPC = vm.programCounter + 1
        case pop:
            vm.nextPC = vm.programCounter + 1

        case mulInt:
            vm.nextPC = vm.programCounter + 1
        case addInt:
            vm.nextPC = vm.programCounter + 1
        case subInt:
            vm.nextPC = vm.programCounter + 1
        case divInt:
            vm.nextPC = vm.programCounter + 1

        case mulFloat:
            vm.nextPC = vm.programCounter + 1
        case addFloat:
            vm.nextPC = vm.programCounter + 1
        case subFloat:
            vm.nextPC = vm.programCounter + 1
        case divFloat:
            vm.nextPC = vm.programCounter + 1

        case sin:
            vm.nextPC = vm.programCounter + 1
        case cos:
            vm.nextPC = vm.programCounter + 1
        case tan:
            vm.nextPC = vm.programCounter + 1
        case arcSin:
            vm.nextPC = vm.programCounter + 1
        case arcCos:
            vm.nextPC = vm.programCounter + 1
        case arcTan:
            vm.nextPC = vm.programCounter + 1

        case sqrt:
            vm.nextPC = vm.programCounter + 1
            
        case lessThan:
            vm.nextPC = vm.programCounter + 1
        case equal:
            vm.nextPC = vm.programCounter + 1
            
        case intToFloat:
            vm.nextPC = vm.programCounter + 1
        case floatToInt:
            vm.nextPC = vm.programCounter + 1
            
        case halt:
            vm.halt = true
        }
    }
}
