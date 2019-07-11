//
//  basicTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 6/21/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

/**
 User-friendly input
 */
func input(name: String, type: String, defaultValue: Any? = nil, intRange:ClosedRange<Int>? = nil, doubleRange: ClosedRange<Double>? = nil, printAfterSec: Bool = false) -> String {
    let typeCode = type.lowercased()

    var pass = false
    var inputResult: String = ""
    
    while !pass {
        if defaultValue == nil {
            print("Please enter \(name): ", terminator: "")
        } else {
            print("Please enter \(name) [\(defaultValue!) by default]: ", terminator: "")
        }
        let response = readLine()
        var inputConverted: Any?
        guard let r: String = response else {
            print("Error: got nil response.")
            continue
        }
        
        if defaultValue != nil && r.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            inputResult = String(describing: defaultValue!)
            break
        }
        
        switch typeCode {
        case "string":
            inputConverted = r
        case "int":
            inputConverted = Int(r)
        case "double":
            inputConverted = Double(r)
        default:
            inputConverted = r
        }
        
        if inputConverted == nil {
            pass = false
            print("Wrong format. Please try again.")
            continue
        } else {
            if doubleRange != nil && typeCode == "double" {
                guard let inputDouble = Double(String(describing: inputConverted!)), doubleRange!.contains(inputDouble) else {
                    pass = false
                    print("Out of range. Please try again.")
                    continue
                }
            } else if intRange != nil && typeCode == "int" {
                guard let inputInt = Int(String(describing: inputConverted!)), intRange!.contains(inputInt) else {
                    pass = false
                    print("Out of range. Please try again.")
                    continue
                }
            }
            pass = true
            inputResult = String(describing: inputConverted!)
        }
    }
    
    if printAfterSec {
        print("\(name) is set as \(inputResult).")
    }
    
    return inputResult
}

/**
 Returns the string of current time.
 */
func timeNow() -> String {
    return displayTime(Date())
}

/**
 Returns the string discribing some time locally. *(More parameters to be added later)*
 */
func displayTime(_ time: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .long
    formatter.timeZone = TimeZone.current
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: time)
}

/**
 Returns a string with given total space `totSpace` filled by empty space after the given string `str`. If the length of the given string is larger than the given total space, it will directly return the string.
 
 - Parameter str: The string to be added empty space after.
 - Parameter totSpace: The total number of space (including the string itself) the string needed to be fitted in.
 
 */
func stringWithSpace(_ str: String, _ totSpace: Int) -> String {
    guard totSpace >= str.count else {
        return str
    }
    
    return str + String(repeating: "\u{0020}", count: totSpace - str.count)
}

/**
 The same as `stringWithSpace`, but it takes `Any` type as the input.
 */
func toPrintWithSpace(_ item: Any, _ totSpace: Int) -> String {
    return stringWithSpace(String(describing: item), totSpace)
}
