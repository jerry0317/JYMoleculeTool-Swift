//
//  mathTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan BA on 6/24/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

/**
 Position vector (three-dimensional)
 */
struct Vector3D {
    var x: Double
    var y: Double
    var z: Double
    
    init(_ x: Double = 0, _ y: Double = 0, _ z: Double = 0){
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(_ dictVec: [Double]){
        self.init()
        self.dictVec = dictVec
    }
    
    subscript(index: Int) -> Double {
        get {
            return dictVec[index]
        }
        set {
            dictVec[index] = newValue
        }
    }
    
    /**
     The magnitude of the vector.
     */
    var magnitude: Double {
        return sqrt(self.*self)
    }
    
    /**
     The array form of the vector. Returns [x,y,z].
     */
    var dictVec: [Double] {
        get {
            return [x, y, z]
        }
        set(newDictVec) {
            x = newDictVec[0]
            y = newDictVec[1]
            z = newDictVec[2]
        }
    }
    
    /**
     Scalar projection of the vector onto another vector (not necessarily normal)
     */
    func scalarProject(on bVec: Vector3D) -> Double {
        return (self .* bVec) / bVec.magnitude
    }
    
    /**
     Vector projection of the vector onto another vector (not necessarily normal)
     */
    func vectorProject(on bVec: Vector3D) -> Vector3D {
        return (scalarProject(on: bVec) / bVec.magnitude) * bVec
    }
    
    /**
     The angle between the self vector and another vector in radian.
     */
    func angleInRad(to bVec: Vector3D) -> Double {
        let cosTheta = (self .* bVec) / (magnitude * bVec.magnitude)
        return acos(cosTheta)
    }
    
    /**
     The angle bewteen the self vector and another vector in degree.
     */
    func angleInDeg(to bVec: Vector3D) -> Double {
        return angleInRad(to: bVec) * 180.0 / Double.pi
    }
    
    /**
     The angle between the self vector and another vector. Returns a measurement with unit in UnitAngle *(Beta)*.
     */
    func angle(to bVec: Vector3D) -> Measurement<UnitAngle> {
        return Measurement(value: angleInRad(to: bVec), unit: UnitAngle.radians)
    }
    
    /**
     The angle between the self vector and another vector. Provided with the desired unit, the function will return the value of the angle. *(Beta)*
     */
    func angle(to bVec: Vector3D, unit: UnitAngle) -> Double {
        return angle(to: bVec).converted(to: unit).value
    }
    
}

extension Vector3D: Hashable {
    static func == (lhs: Vector3D, rhs: Vector3D) -> Bool {
        return
            lhs.x == rhs.x &&
                lhs.y == rhs.y &&
                lhs.z == rhs.z
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
    
}

extension Vector3D: CustomStringConvertible {
    var description: String {
        return String(describing: dictVec)
    }
}

prefix operator -
extension Vector3D {
    /**
     Inverse Vector
     */
    static prefix func - (vector: Vector3D) -> Vector3D {
        return Vector3D(-vector.x, -vector.y, -vector.z)
    }
}

infix operator +: AdditionPrecedence
infix operator -: AdditionPrecedence
infix operator .*: MultiplicationPrecedence
infix operator **: MultiplicationPrecedence
infix operator *: MultiplicationPrecedence
infix operator /: MultiplicationPrecedence
extension Vector3D {
    /**
     Vector Addition
     */
    static func + (left: Vector3D, right: Vector3D) -> Vector3D {
        return Vector3D(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    /**
     Vector Subtraction
     */
    static func - (left: Vector3D, right: Vector3D) -> Vector3D {
        return Vector3D(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    /**
     Dot Product
     */
    static func .* (left: Vector3D, right: Vector3D) -> Double {
        return left.x * right.x + left.y * right.y + left.z * right.z
    }
    /**
     Cross Product
     */
    static func ** (left: Vector3D, right: Vector3D) -> Vector3D {
        return Vector3D(left.y * right.z - left.z * right.y, left.z * right.x - left.x * right.z, left.x * right.y - left.y * right.x)
    }
    /**
     Scalar Product
     */
    static func * (left: Double, right: Vector3D) -> Vector3D {
        return Vector3D(left * right.x, left * right.y, left * right.z)
    }
    /**
     Scalar Product
     */
    static func * (left: Vector3D, right: Double) -> Vector3D {
        return Vector3D(left.x * right, left.y * right, left.z * right)
    }
    /**
     Scalar Product (Division)
     */
    static func / (left: Vector3D, right: Double) -> Vector3D {
        return Vector3D(left.x / right, left.y / right, left.z / right)
    }
}

struct Matrix {
    let rows: Int
    let columns: Int
    
    private var grid: [Double]
    
    var size: (Int, Int) {
        return (rows, columns)
    }
    
    var content: [[Double]] {
        return grid.chunked(into: columns)
    }
    
    init(_ rows: Int, _ columns: Int) {
        precondition(rows >= 0 && columns >= 0, "Rows and columns must be non-negative")
        self.rows = rows
        self.columns = columns
        self.grid = .init(repeating: 0, count: rows * columns)
    }
    
    init(_ rows: Int, _ columns: Int, repeatedValue: Double) {
        self.init(rows, columns)
        self.grid = .init(repeating: repeatedValue, count: rows * columns)
    }
    
    init(_ rows: Int, _ columns: Int, grid: [Double]) {
        self.init(rows, columns)
        self.grid = grid
    }
    
    func indexIsValid(_ row: Int, _ column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Double {
        get {
            precondition(indexIsValid(row, column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            precondition(indexIsValid(row, column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
    
}

extension Matrix: Hashable {
    static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.rows == rhs.rows && lhs.columns == rhs.columns && lhs.grid == rhs.grid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(rows)
        hasher.combine(columns)
        hasher.combine(grid)
    }
}

extension Matrix: CustomStringConvertible {
    var description: String {
        return String(describing: content)
    }
}

extension Matrix {
    var numOfElements: Int {
        return rows * columns
    }
    
    func negated() -> Matrix {
        return Matrix(rows, columns, grid: self.grid.map { -$0 })
    }
}

extension Matrix {
    static prefix func - (matrix: Matrix) -> Matrix {
        return matrix.negated()
    }
}

extension Matrix {
    static func + (lhs: Matrix, rhs: Matrix) -> Matrix {
        guard lhs.size == rhs.size else {
            fatalError("Try to add matrices of different sizes.")
        }
        let grid = (0...lhs.numOfElements - 1).map({lhs.grid[$0] + rhs.grid[$0]})
        return Matrix(lhs.rows, lhs.columns, grid: grid)
    }
    
    static func - (lhs: Matrix, rhs: Matrix) -> Matrix {
        return lhs + (-rhs)
    }
}

extension Matrix {
    /**
     Credit: https://github.com/hollance/Matrix/blob/master/Matrix.swift
     */
    var matrixForm: String {
        var description = ""
        
        for i in 0..<rows {
            let contents = (0..<columns).map{ String(format: "%-12g", self[i, $0]) }.joined(separator: " ")
            
            switch (i, rows) {
            case (0, 1):
                description += "( \(contents) )\n"
            case (0, _):
                description += "⎛ \(contents) ⎞\n"
            case (rows - 1, _):
                description += "⎝ \(contents) ⎠\n"
            default:
                description += "⎜ \(contents) ⎥\n"
            }
        }
        return description
    }
}

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

/**
 - Credit: https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
 */
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
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

/**
 Utilize the cache to implement the memoized dynamic programming of combinations. Stores the combinations of indices in to the cache.
 */
func combinationsDynProgrammed<T>(_ elements: Array<T>, _ k: Int) -> Set<Set<T>> {
    let n = elements.count
    let indices = Array(0...(n - 1))
    let combTuple = CombTuple(n,k)
    var indexComb = globalCache.indexCombinations[combTuple]
    
    if indexComb == nil {
        indexComb = combinations(indices, k)
        globalCache.indexCombinations[combTuple] = indexComb
    }
    
    return Set(indexComb!.map({ Set($0.map({ elements[$0] })) }))
}

extension Array where Element: Equatable {
    func cyclicallyNext(to item: Element, distance: Int = 1) -> Element? {
        guard let index = self.firstIndex(of: item) else {
            return nil
        }
        
        let indexAfter = self.index(index, cyclicallyOffsetBy: distance)
        return self[indexAfter]
    }
    
    func index(cyclicallyAfter i: Int) -> Int {
        return index(i, cyclicallyOffsetBy: 1)
    }
    
    func index(_ i: Int, cyclicallyOffsetBy k: Int) -> Int {
        guard count != 0 else {
            return startIndex
        }
        let r = k % count
        if i + r >= endIndex {
            return i + r - endIndex
        } else if i + r < startIndex {
            return i + r + endIndex
        } else {
            return i + r
        }
    }
}

extension Array {
    func cyclicTransformed() -> [[Element]] {
        var transformedList = [self]
        var beingTransformed = self
        for (i, _) in self.enumerated() {
            if i < endIndex - 1 {
                let first = beingTransformed.removeFirst()
                beingTransformed.append(first)
                transformedList.append(beingTransformed)
            }
        }
        return transformedList
    }
}
