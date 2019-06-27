//
//  mathTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan BA on 6/24/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

extension Double {
    func rounded(digitsAfterDecimal digit: Int) -> Double{
        let power = Double(pow(10, Double(digit)))
        var x = self * power
        x.round()
        x = x / power
        return x
    }
    
    mutating func round(digitsAfterDecimal digit: Int) {
        self = self.rounded(digitsAfterDecimal: digit)
    }
}

extension Array where Element == Double {
    func rounded(digitsAfterDecimal digit: Int) -> [Double]{
        return self.map({$0.rounded(digitsAfterDecimal: digit)})
    }
    
    mutating func round(digitsAfterDecimal digit: Int) {
        self = self.rounded(digitsAfterDecimal: digit)
    }
}

/**
 Combination function for an array.
 
 - **Credit** for inspiration: `https://stackoverflow.com/questions/25162500/apple-swift-generate-combinations-with-repetition`
 */
func combinations<T>(_ elements: Array<T>, _ k: Int) -> Set<Set<T>> {
    return combinations(ArraySlice(elements), k)
}

func combinations<T>(_ elements: ArraySlice<T>, _ k: Int) -> Set<Set<T>> {
    if k <= 0 {
        return Set([Set()])
    }
    
    if elements.count <= 0 {
        return Set()
    }
    
    var remainingElements = elements
    var result: Set<Set<T>> = Set()
    
    for e in elements {
        let head = Set([e])
        remainingElements.removeFirst()
        let subCombinations = combinations(remainingElements, k - 1)
        let subResult = Set(subCombinations.map { $0.union(head) })
        result = result.union(subResult)
    }
    
    return result
}
