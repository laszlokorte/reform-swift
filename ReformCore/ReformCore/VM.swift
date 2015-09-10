//
//  VM.swift
//  ReformCore
//
//  Created by Laszlo Korte on 09.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//


typealias VMInstruction = Int
typealias VMProgramm = [VMInstruction]

enum VMError : ErrorType {
    case InvalidInstruction
}

class VM {
    private var memory = [Int]()
    private var stack = [Int]()
    private var halt = true
    private var programCounter: Int = 0
    private var nextPC : Int? = nil

    func run(program: VMProgramm) throws {
        programCounter = 0
        halt = false
        while !halt && programCounter < program.count {
            guard let instruction = VMOperatation(rawValue: program[programCounter]) else {
                throw VMError.InvalidInstruction
            }
            instruction.executeOn(self)
            programCounter = nextPC ?? programCounter + 1
        }
    }
}

enum VMOperatation : VMInstruction {
    case PushImmediate
    case Load
    case Store
    case Pop

    case MulInt
    case AddInt
    case SubInt
    case DivInt

    case MulFloat
    case AddFloat
    case SubFloat
    case DivFloat

    case Sin
    case Cos
    case Tan
    case ArcSin
    case ArcCos
    case ArcTan

    case Sqrt

    case LessThan
    case Equal

    case IntToFloat
    case FloatToInt

    case Halt

    private func executeOn(vm: VM) {
        switch self {
        case PushImmediate:

            vm.nextPC = vm.programCounter + 1
        case Load:
            vm.nextPC = vm.programCounter + 1
        case Store:
            vm.nextPC = vm.programCounter + 1
        case Pop:
            vm.nextPC = vm.programCounter + 1

        case MulInt:
            vm.nextPC = vm.programCounter + 1
        case AddInt:
            vm.nextPC = vm.programCounter + 1
        case SubInt:
            vm.nextPC = vm.programCounter + 1
        case DivInt:
            vm.nextPC = vm.programCounter + 1

        case MulFloat:
            vm.nextPC = vm.programCounter + 1
        case AddFloat:
            vm.nextPC = vm.programCounter + 1
        case SubFloat:
            vm.nextPC = vm.programCounter + 1
        case DivFloat:
            vm.nextPC = vm.programCounter + 1

        case Sin:
            vm.nextPC = vm.programCounter + 1
        case Cos:
            vm.nextPC = vm.programCounter + 1
        case Tan:
            vm.nextPC = vm.programCounter + 1
        case ArcSin:
            vm.nextPC = vm.programCounter + 1
        case ArcCos:
            vm.nextPC = vm.programCounter + 1
        case ArcTan:
            vm.nextPC = vm.programCounter + 1

        case Sqrt:
            vm.nextPC = vm.programCounter + 1
            
        case LessThan:
            vm.nextPC = vm.programCounter + 1
        case Equal:
            vm.nextPC = vm.programCounter + 1
            
        case IntToFloat:
            vm.nextPC = vm.programCounter + 1
        case FloatToInt:
            vm.nextPC = vm.programCounter + 1
            
        case Halt:
            vm.halt = true
        }
    }
}