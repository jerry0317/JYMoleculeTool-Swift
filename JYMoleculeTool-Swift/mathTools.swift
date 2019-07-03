//
//  mathTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan BA on 6/24/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

extension Double {
    /**
     Return the rounded result of a Double with certain digits after decimal.
     */
    func rounded(digitsAfterDecimal digit: Int) -> Double{
        let power = Double(pow(10, Double(digit)))
        var x = self * power
        x.round()
        x = x / power
        return x
    }
    
    /**
     Round a Double with certain digits after decimal.
     */
    mutating func round(digitsAfterDecimal digit: Int) {
        self = self.rounded(digitsAfterDecimal: digit)
    }
}

extension Array where Element == Double {
    /**
     Return an array contains Double each rounded certain digits after decimal.
     */
    func rounded(digitsAfterDecimal digit: Int) -> [Double]{
        return self.map({$0.rounded(digitsAfterDecimal: digit)})
    }
    
    /**
     Round each Double in an array with certain digits after decimal.
     */
    mutating func round(digitsAfterDecimal digit: Int) {
        self = self.rounded(digitsAfterDecimal: digit)
    }
}

/**
 Combination function for an array.
 
 - Complexity: O(C(n,k))
 
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
        let head: Set<T> = [e]
        remainingElements.removeFirst()
        let subCombinations = combinations(remainingElements, k - 1)
        guard !subCombinations.isEmpty else {
            continue
        }
        let subResult = Set(subCombinations.map { $0.union(head) })
        result = result.union(subResult)
    }
    
    return result
}
