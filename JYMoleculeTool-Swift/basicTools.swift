//
//  basicTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan BA on 6/21/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

/**
 User-friendly input
 */
@discardableResult
func input(name: String, type: String) -> Any {
    let typeCode = type.lowercased()

    var pass = false
    var inputResult: Any = ""
    
    while !pass {
        print("Please enter \(name): ", terminator: "")
        let response = readLine()
        var inputConverted: Any?
        guard let r: String = response else {
            print("Error: got nil response.")
            continue
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
            pass = true
            inputResult = inputConverted!
        }
    }
    
    return inputResult
}
