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
public struct Vector3D {
    public var x: Double
    public var y: Double
    public var z: Double
    
    public init(_ x: Double = 0, _ y: Double = 0, _ z: Double = 0){
        self.x = x
        self.y = y
        self.z = z
    }
    
    public init(_ dictVec: [Double]){
        self.init()
        self.dictVec = dictVec
    }
    
    public subscript(index: Int) -> Double {
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
    public var magnitude: Double {
        return sqrt(self.*self)
    }
    
    /**
     The array form of the vector. Returns [x,y,z].
     */
    public var dictVec: [Double] {
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
    public func scalarProject(on bVec: Vector3D) -> Double {
        return (self .* bVec) / bVec.magnitude
    }
    
    /**
     Vector projection of the vector onto another vector (not necessarily normal)
     */
    public func vectorProject(on bVec: Vector3D) -> Vector3D {
        return (scalarProject(on: bVec) / bVec.magnitude) * bVec
    }
    
    /**
     The angle between the self vector and another vector in radian.
     */
    public func angleInRad(to bVec: Vector3D) -> Double {
        let cosTheta = (self .* bVec) / (magnitude * bVec.magnitude)
        return acos(cosTheta)
    }
    
    /**
     The angle bewteen the self vector and another vector in degree.
     */
    public func angleInDeg(to bVec: Vector3D) -> Double {
        return angleInRad(to: bVec) * 180.0 / Double.pi
    }
    
    /**
     The angle between the self vector and another vector. Returns a measurement with unit in UnitAngle *(Beta)*.
     */
    public func angle(to bVec: Vector3D) -> Measurement<UnitAngle> {
        return Measurement(value: angleInRad(to: bVec), unit: UnitAngle.radians)
    }
    
    /**
     The angle between the self vector and another vector. Provided with the desired unit, the function will return the value of the angle. *(Beta)*
     */
    public func angle(to bVec: Vector3D, unit: UnitAngle) -> Double {
        return angle(to: bVec).converted(to: unit).value
    }
    
}

extension Vector3D: Hashable {
    public static func == (lhs: Vector3D, rhs: Vector3D) -> Bool {
        return
            lhs.x == rhs.x &&
                lhs.y == rhs.y &&
                lhs.z == rhs.z
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
    
}

extension Vector3D: CustomStringConvertible {
    public var description: String {
        return String(describing: dictVec)
    }
}

prefix operator -
public extension Vector3D {
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
public extension Vector3D {
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

public struct Matrix {
    /**
     The number of rows of the matrix.
     */
    public let rows: Int
    
    /**
     The number of columns of the matrix.
     */
    public let columns: Int
    
    /**
     Privately-accessable grid to store the entries of the matrix row-by-row.
     */
    private var _grid: [Double]
    
    /**
     Grid to store/access the entries of the matrix row-by-row.
     */
    public var grid: [Double] {
        get {
            return _grid
        }
        set {
            _setNewGrid(newValue)
        }
    }
    
    /**
     Grid to store/access the entris of the matrix column-by-column.
     */
    public var columnGrid: [Double] {
        get {
            listOfColumns.flatMap { $0 }
        }
        set {
            
        }
    }
    
    /**
     The size (dimension) of the matrix. Returns `(rows, columns)` as a tuple.
     */
    public var size: (Int, Int) {
        return (rows, columns)
    }
    
    /**
     The standard 2-D array to represent the matrix. (The array of rows)
     */
    public var content: [[Double]] {
        get {
            listOfRows
        }
        set {
            _setNewRows(newValue)
        }
    }
    
    /**
     The 2-D array to represent the rows.
     */
    public var listOfRows: [[Double]] {
        get {
            if columns > 0 {
                return grid.chunked(into: columns)
            } else {
                return .init(repeating: [], count: rows)
            }
        }
        set {
            _setNewRows(newValue)
        }
    }
    
    /**
     The 2-D array to represent the columns.
     */
    public var listOfColumns: [[Double]] {
        get {
            _transposeTransform(columns, columns, grid: grid)
        }
        set {
            _setNewColumns(newValue)
        }
    }
    
    public init(_ rows: Int, _ columns: Int) {
        precondition(rows >= 0 && columns >= 0, "Rows and columns must be non-negative.")
        self.rows = rows
        self.columns = columns
        self._grid = .init(repeating: 0, count: rows * columns)
    }
    
    public init(_ rows: Int, _ columns: Int, repeatedValue: Double) {
        self.init(rows, columns)
        self.grid = .init(repeating: repeatedValue, count: rows * columns)
    }
    
    public init(_ rows: Int, _ columns: Int, grid: [Double]) {
        self.init(rows, columns)
        self.grid = grid
    }
    
    public init(_ rows: Int, _ columns: Int, content: [[Double]]) {
        self.init(rows, columns)
        self.content = content
    }
    
    public init?(_ content: [[Double]]) {
        let m = content.count
        let n = (m == 0 ? 0 : content[0].count)
        var newMatrix = Matrix(m, n)
        let check = newMatrix._setNewRows(content)
        if check {
            self = newMatrix
        } else {
            return nil
        }
    }
    
    /**
     To determine if a set of indices (row and column) are valid in this matrix.
     */
    public func indexIsValid(_ row: Int, _ column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    @discardableResult
    mutating func _setNewGrid(_ newValue: [Double]) -> Bool {
        guard newValue.count == numOfElements else {
            return false
        }
        _grid = newValue
        return true
    }
    
    @discardableResult
    mutating func _setNewColumnGrid(_ newValue: [Double]) -> Bool {
        guard newValue.count == numOfElements else {
            return false
        }
        listOfRows = _transposeTransform(rows, rows, grid: grid)
        return true
    }
    
    @discardableResult
    mutating func _setNewRows(_ newValue: [[Double]]) -> Bool {
        let columnIdentifier = newValue.reduce(true) { (check, row) in
            check ? row.count == columns : false
        }
        guard newValue.count == rows && columnIdentifier else {
            print("Fail to interpret the 2-D array.")
            return false
        }
        let newGrid = newValue.flatMap { $0 }
        grid = newGrid
        return true
    }
    
    @discardableResult
    mutating func _setNewColumns(_ newValue: [[Double]]) -> Bool {
        let rowIdentifier = newValue.reduce(true) { (check, column) in
            check ? column.count == rows : false
        }
        guard newValue.count == columns && rowIdentifier else {
            print("Fail to interpret the 2-D array.")
            return false
        }
        return _setNewColumnGrid(newValue.flatMap { $0 })
    }
    
    private func _transposeTransform(_ a: Int, _ b: Int, grid: [Double]) -> [[Double]] {
        (0..<a).map { stride(from: $0, to: grid.endIndex, by: b).map({ grid[$0] }) }
    }
    
    public subscript(row: Int, column: Int) -> Double {
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
    public static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.rows == rhs.rows && lhs.columns == rhs.columns && lhs.grid == rhs.grid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rows)
        hasher.combine(columns)
        hasher.combine(grid)
    }
}

extension Matrix: CustomStringConvertible {
    public var description: String {
        return String(describing: content)
    }
}

public extension Matrix {
    /**
     The number of entries in the matrix.
     */
    var numOfElements: Int {
        rows * columns
    }
    
    /**
     Check if the number of rows is equal to the number of columns.
     */
    var isSquareMatrix: Bool {
        rows == columns
    }
    
    /**
     The negated matrix.
     */
    func negated() -> Matrix {
        Matrix(rows, columns, grid: self.grid.map { -$0 })
    }
    
    /**
     The transpose of the matrix.
     */
    func transpose() -> Matrix {
        Matrix(columns, rows, grid: columnGrid)
    }
    
    /**
     The submatrix of the matrix by eliminating given row and column.
     */
    func subMatrix(_ row: Int, _ column: Int) -> Matrix {
        precondition(indexIsValid(row, column), "Index out of range")
        var newContent = listOfColumns
        newContent.remove(at: column)
        newContent = _transposeTransform(rows, rows, grid: newContent.flatMap { $0 })
        newContent.remove(at: row)
        return Matrix(rows - 1, columns - 1, content: newContent)
    }
    
    /**
     The trace of the matrix.
     */
    func trace() -> Double {
        (0..<min(rows, columns)).reduce(0.0, { $0 + self[$1, $1] })
    }
    
    /**
     The determinant of  a square matrix. If the matrix is not a square matrix, it returns `Double.nan`.
     */
    func determinant() -> Double {
        guard isSquareMatrix else {
            return Double.nan
        }
        let n = rows
        
        switch n {
        case 0:
            return 0
        case 1:
            return self[0,0]
        default:
            var resultValue: Double = 0.0
            for i in 0..<n {
                let ai = (i % 2 == 0) ? self[0, i] : -self[0, i]
                if ai.isZero {
                    continue
                }
                resultValue = resultValue + ai * subMatrix(0, i).determinant()
            }
            return resultValue
        }
    }
    
    /**
     Shorthand for the determinant.
     */
    func det() -> Double {
        determinant()
    }
}

public extension Matrix {
    /**
     The identity matrix.
     */
    static func eye(_ rows: Int, _ columns: Int, value: Double = 1) -> Matrix {
        var eyeMatrix = Matrix(rows, columns)
        let k = min(rows, columns)
        for i in 0..<k {
            eyeMatrix[i, i] = value
        }
        return eyeMatrix
    }
}

public extension Matrix {
    /**
     The negation of a matrix.
     */
    static prefix func - (matrix: Matrix) -> Matrix {
        return matrix.negated()
    }
}

public extension Matrix {
    /**
     Matrix Addition
     */
    static func + (lhs: Matrix, rhs: Matrix) -> Matrix {
        guard lhs.size == rhs.size else {
            fatalError("Try to add matrices of different sizes.")
        }
        let grid = (0...lhs.numOfElements - 1).map({lhs.grid[$0] + rhs.grid[$0]})
        return Matrix(lhs.rows, lhs.columns, grid: grid)
    }
    
    /**
     Matrix Subtraction
     */
    static func - (lhs: Matrix, rhs: Matrix) -> Matrix {
        lhs + (-rhs)
    }
    
    /**
     Scalar Product
     */
    static func * (lhs: Double, rhs: Matrix) -> Matrix {
        let grid = rhs.grid.map { lhs * $0 }
        return Matrix(rhs.rows, rhs.columns, grid: grid)
    }
    
    /**
     Scalar Product
     */
    static func * (lhs: Matrix, rhs: Double) -> Matrix {
        rhs * lhs
    }
    
    /**
     Matrix multiplication
     */
    static func * (lhs: Matrix, rhs: Matrix) -> Matrix? {
        guard lhs.columns == rhs.rows else {
            return nil
        }
        
        let (m, n, p) = (lhs.columns, lhs.rows, rhs.columns)
        var grid = [Double]()
        for i in 0..<n {
            for j in 0..<p {
                grid.append((0...(m - 1)).reduce(0, {
                    (sum, k) in
                    sum + lhs[i, k] * rhs[k, j]
                }))
            }
        }
        return Matrix(n, p, grid: grid)
    }
}

postfix operator ′

public extension Matrix {
    static postfix func ′ (value: Matrix) -> Matrix {
        value.transpose()
    }
}

public extension Matrix {
    /**
     Gives a string to represent the matrix form of the matrix.
     - Credit: https://github.com/hollance/Matrix/blob/master/Matrix.swift
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

public extension Double {
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

public extension Array {
    /**
     Separate an array into a 2-D array with each sub-array having the same given size.
     - Credit: https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
     */
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

public extension Array where Element == Double {
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
public func combinations<T>(_ elements: Array<T>, _ k: Int) -> Set<Set<T>> {
    return combinations(ArraySlice(elements), k)
}

public func combinations<T>(_ elements: ArraySlice<T>, _ k: Int) -> Set<Set<T>> {
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
public func combinationsDynProgrammed<T>(_ elements: Array<T>, _ k: Int) -> Set<Set<T>> {
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

public extension Array where Element: Equatable {
    /**
     In the cyclic transformation, gives the next item to some item in the array, with certain distance (default 1). If the distance is negative, then it gives the item before (with certain distance) to the item.
     */
    func cyclicallyNext(to item: Element, distance: Int = 1) -> Element? {
        guard let index = self.firstIndex(of: item) else {
            return nil
        }
        
        let indexAfter = self.index(index, cyclicallyOffsetBy: distance)
        return self[indexAfter]
    }
    
    /**
     The index cylically after a given index.
     */
    func index(cyclicallyAfter i: Int) -> Int {
        return index(i, cyclicallyOffsetBy: 1)
    }
    
    /**
     The index with cylic transformation certain times.
     */
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

public extension Array {
    /**
     Gives a 2-D array consists of every possible cyclic transformation over the array.
     */
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

extension Array where Element : RangeReplaceableCollection {

    typealias InnerCollection = Element
    typealias InnerElement = InnerCollection.Iterator.Element

    /**
     The cartesian product among the members of the array.
     
     - Example: `[[1],[2,3]].cartesianProduct() = [[1,2],[2,3]].`
     - The total number of elements equal to the product of the count of all the sub-arrays.
     */
    func cartesianProduct(ignoreEmpties: Bool = false) -> [[InnerElement]] {
        if isEmpty {
            return []
        }
        
        var dims = self
        if ignoreEmpties {
            dims.removeAll(where: { $0.isEmpty })
        } else {
            if dims.contains(where: { $0.isEmpty }) {
                return []
            }
        }
        
        let totalElements = self.reduce(0, { $0 + $1.count })
        var result: [[InnerElement]] = [[]]
        result.reserveCapacity(totalElements)
        for dim in self {
            let oldResult = result
            var newResult = [[InnerElement]]()
            for oldGroup in oldResult {
                for newElement in dim {
                    newResult.append(oldGroup + [newElement])
                }
            }
            result = newResult
        }
        
        return result
    }
}

public struct HashPoint {
    public var value: Int
    
    public init(_ value: Int) {
        self.value = value
    }
}

extension HashPoint: Hashable {
    public static func == (lhs: HashPoint, rhs: HashPoint) -> Bool {
        return lhs.value == rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

extension HashPoint: Comparable {
    public static func < (lhs: HashPoint, rhs: HashPoint) -> Bool {
        lhs.hashValue < rhs.hashValue
    }
}

public struct HashEdge {
    private var _point1: HashPoint
    private var _point2: HashPoint
    
    public var points: [HashPoint] {
        get {
            return [_point1, _point2].sorted()
        }
        set {
            assignSortedPoints(newValue)
        }
    }
    
    public var value: Int
    
    public init(_ point1: HashPoint, _ point2: HashPoint, _ value: Int){
        let sortedPoints = [point1, point2].sorted()
        self._point1 = sortedPoints[0]
        self._point2 = sortedPoints[1]
        self.value = value
    }
    
    public init(points: [HashPoint], value: Int){
        precondition(points.count >= 2, "Must provide an argument of at least two points")
        self.init(points[0], points[1], value)
    }
    
    public init(hashValues: [Int], value: Int){
        self.init(points: hashValues.map({ HashPoint($0) }), value: value)
    }
    
    private mutating func assignSortedPoints(_ points: [HashPoint]) {
        guard points.count == 2 else {
            return
        }
        let sortedPoints = points.sorted()
        _point1 = sortedPoints[0]
        _point2 = sortedPoints[1]
    }
}

extension HashEdge: Hashable {
    public static func == (lhs: HashEdge, rhs: HashEdge) -> Bool {
        return lhs.points == rhs.points && lhs.value == rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(points)
        hasher.combine(value)
    }
}

extension HashEdge: Comparable {
    public static func < (lhs: HashEdge, rhs: HashEdge) -> Bool {
        lhs.hashValue < rhs.hashValue
    }
}

public struct HashGraph {
    public var points: [HashPoint] = []
    public var edges: [HashEdge] = []
}

extension HashGraph: Hashable {
    public static func == (lhs: HashGraph, rhs: HashGraph) -> Bool {
        return lhs.points.sorted() == rhs.points.sorted() && lhs.edges.sorted() == rhs.edges.sorted()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(points.sorted())
        hasher.combine(edges.sorted())
    }
}
