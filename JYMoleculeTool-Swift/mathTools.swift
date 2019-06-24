//
//  mathTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan BA on 6/24/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

extension Double {
    func rounded(digitsAfterDecimal digit: Double) -> Double{
        let power = pow(10, digit)
        var x = self * power
        x.round()
        x = x / power
        return x
    }
    
    mutating func round(digitsAfterDecimal digit: Double) {
        self = self.rounded(digitsAfterDecimal: digit)
    }
}

extension Array where Element == Double {
    func rounded(digitsAfterDecimal digit: Double) -> [Double]{
        return self.map({$0.rounded(digitsAfterDecimal: digit)})
    }
    
    mutating func round(digitsAfterDecimal digit: Double) {
        self = self.rounded(digitsAfterDecimal: digit)
    }
}
