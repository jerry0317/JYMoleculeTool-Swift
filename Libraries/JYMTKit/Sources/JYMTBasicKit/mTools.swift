//
//  mTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 6/20/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

#if os(Linux)
import Glibc // Linux optimization for updated printing behavior
#else
#endif

// MARK: Basics

// TODO: Implement Copy-on-write

/**
 Atom
 
 - Designed to be a final class (access through reference) for memory optimization.
 */
public final class Atom {
    /**
     The name of the atom.
     */
    public var name: String {
        get {
            return element?.rawValue ?? ""
        }
        set(newName) {
            element = ChemElement(rawValue: newName)
        }
    }
    
    /**
     The chemical element of the atom.
     */
    public var element: ChemElement?
    
    /**
     The atomic mass of the atom, with unit in amu. If not specified, it will return the atomic mass of the element of the atom.
     */
    public var atomicMass: Double? {
        get {
            if element == nil {
                return nil
            } else if storedMassNumber == nil {
                return element!.atomicMass
            } else {
                return element!.isotopeAtomicMasses[storedMassNumber!]
            }
        }
    }
    
    private var storedMassNumber: Int?
    
    public var massNumber: Int? {
        get {
            if element == nil {
                return nil
            } else {
                return storedMassNumber
            }
        }
        set {
            storedMassNumber = newValue
        }
    }
    
    /**
     The atomic mass of the atom, with unit in kg. If not specified, it will return the atomic mass of the element of the atom.
    */
    public var mass: Double? {
        get {
            atomicMass == nil ? nil : atomicMass! * PhysConst.amu
        }
    }
    
    /**
     The position vector of the atom.
     */
    public var rvec: Vector3D?
    
    /**
     The optional identifier of the atom to trace it down after making the eight possible atoms from re-sigining. Does not effect the hash value.
     */
    public var identifier: Int?
    
    public convenience init(_ name: String, _ rvec: Vector3D? = nil, _ identifier: Int? = nil, massNumber: Int? = nil){
        let element = ChemElement(rawValue: name)
        self.init(element, rvec, identifier, massNumber: massNumber)
    }
    
    public init(_ element: ChemElement?, _ rvec: Vector3D? = nil, _ identifier: Int? = nil, massNumber: Int? = nil){
        self.element = element
        self.rvec = rvec
        self.identifier = identifier
        
        if massNumber != nil {
            self.massNumber = massNumber
        }
    }
    
    /**
     Possible atoms after re-signing it.
     */
    public var possibles: [Atom] {
        return findPossiblesDynProgrammed()
    }
    
    /**
     Find the eight possible atom (differ in rvec) after re-signing.
     */
    private func findPossibles() -> [Atom] {
        if rvec == nil {
            return []
        } else {
            let possibleRvecList = rvec!.resign()
            return Array(Set(possibleRvecList.map { Atom(element, $0, identifier, massNumber: massNumber) }))
        }
    }
    
    /**
     Use cache to implement memoized dynamic programming to find possibles.
     */
    private func findPossiblesDynProgrammed() -> [Atom] {
        if globalCache.atomPossibles[self] != nil {
            return globalCache.atomPossibles[self]!
        } else {
            let possibles = findPossibles()
            globalCache.atomPossibles[self] = possibles
            return possibles
        }
    }
    
    /**
     The valence of the atom. If there's no known valence, then it returns 0.
     */
    public var valence: Int {
        guard let e = element else {
            return 0
        }
        return ChemConst.valences[e] ?? 0
    }
    
    /**
     Trim down the component of the position vector of an atom to zero if the absolute value of that component is less than the trim level.
     */
    @discardableResult
    public func trimDownRVec(level trimLevel: Double = 0.01) -> Bool {
        guard rvec != nil else {
            return false
        }
        for i in 0...2 {
            if abs(rvec!.dictVec[i]) <= trimLevel {
                rvec!.dictVec[i] = 0
            }
        }
        return true
    }
    
    /**
     Round the component of the position vector to provided digits after decimal.
     */
    @discardableResult
    public func roundRVec(digitsAfterDecimal digit: Int) -> Bool {
        guard rvec != nil else {
            return false
        }
        for i in 0...2 {
            rvec!.dictVec[i].round(digitsAfterDecimal: digit)
        }
        return true
    }
    
    /**
     Set the identifier of the atom based on the hash value of the element and rvec.
     */
    public func setIdentifier() {
        var hasher = Hasher()
        hasher.combine(element)
        hasher.combine(rvec)
        identifier = hasher.finalize()
    }
}

extension Atom: Hashable {
    public static func == (lhs: Atom, rhs: Atom) -> Bool {
        return
            lhs.element == rhs.element &&
            lhs.rvec == rhs.rvec
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(element)
        hasher.combine(rvec)
    }
}

infix operator .=: ComparisonPrecedence
public extension Atom {
    /**
     With the same identifier
     
     - Returns:
        - `true` if the two atoms have the same identifier.
        -  `false` if any of the two identifiers is `nil` or the two atoms have the different identifier.
     */
    static func .= (lhs: Atom, rhs: Atom) -> Bool {
        guard let lid = lhs.identifier, let rid = rhs.identifier else {
            return false
        }
        return lid == rid
    }
}

/**
 Chemical bond type (between two atoms)
 
- Designed to be a final class (access through reference) for memory optimization.
 */
public final class ChemBondType {
    /**
     The names of the two atoms in the chemical bond.
     */
    public var atomNames: Array<String> {
        get {
            let atomList = atomElementArray
            switch atomList.count {
            case 1:
                return [atomList[0].rawValue, atomList[0].rawValue]
            case 2:
                return [atomList[0].rawValue, atomList[1].rawValue]
            default:
                return []
            }
        }
        set(newValue) {
            var eList: Set<ChemElement> = []
            for newName in newValue {
                guard let newElement = ChemElement(rawValue: newName) else {
                    return
                }
                eList.insert(newElement)
            }
            atomElements = eList
        }
    }
    
    /**
     The **set** of elements of the two atoms in the chemical bond.
     */
    public var atomElements: Set<ChemElement>
    
    /**
     The **array** of elements of the two atoms in the chemical bond. Not accessible from outside.
     */
    private var atomElementArray: [ChemElement] {
        return Array(atomElements)
    }

    /**
     The order of the bond.
     */
    public var order: Int
    
    public init(_ atom1: String, _ atom2: String, _ bondOrder: Int = 1){
        self.atomElements = []
        self.order = bondOrder
        self.atomNames = [atom1, atom2]
    }
    
    public init(_ element1: ChemElement, _ element2: ChemElement, _ bondOrder: Int = 1){
        self.atomElements = [element1, element2]
        self.order = bondOrder
    }
    
    /**
     The bond code for the bond. For example, the single carbon-carbon bond is denoted as .CC1.
     */
    public var bdCode: BondCode? {
        return findBdCodeDynProgrammed()
    }
    
    /**
     The bond length of this bond type.
     */
    public var length: Double? {
        guard let bd = bdCode else {
            return nil
        }
        return bondLengths[bd]
    }
    
    /**
     An optional `ClosedRange<Double>?` to represent the bond length range.
     */
    public var lengthRange: ClosedRange<Double>? {
        guard let bd = bdCode else {
            return nil
        }
        let (lb, ub) = ChemConst.bondLengthRangeTuples[bd]!
        return lb...ub
    }
    
    /**
     An optional tuple `(Double, Double)?` to present the min and the max of the bond length range.
     */
    public var lengthRangeTuple: (Double, Double)? {
        guard let bd = bdCode else {
            return nil
        }
        return ChemConst.bondLengthRangeTuples[bd]!
    }
    
    /**
     The dictionary storing the known bond lengths.
     */
    private var bondLengths: [BondCode: Double] {
        return ChemConst.bondLengths
    }
    
    /**
     A set storing disabled bdcodes (mainly for debug use).
     */
    static let disabledBondCodes: Set<BondCode> = []
    
    /**
     The validity of a bond type.
     */
    public var isValid: Bool {
        validate()
    }
    
    /**
     Tells if a bond type is valid.
     */
    public func validate() -> Bool{
        return bdCode != nil && !ChemBondType.disabledBondCodes.contains(bdCode!)
    }
    
    /**
     Use cache to implement the memoized dynamic programming to find the bond code of the type.
     */
    public func findBdCodeDynProgrammed() -> BondCode? {
        guard let bdCodeInCache = globalCache.bdCodes[self] else {
            let newBdCode = findBdCode()
            globalCache.bdCodes[self] = newBdCode
            return newBdCode
        }
        return bdCodeInCache
    }
    
    /**
     Find the bond code of the bond type.
     */
    public func findBdCode() -> BondCode? {
        return BondCode(rawValue: findBdCodeString())
    }
    
    /**
     Find the string of the bond code of the bond type.
     */
    public func findBdCodeString() -> String {
        var atomNamesArray = atomNames
        if atomNamesArray[0] > atomNamesArray[1] {
            atomNamesArray.swapAt(0, 1)
        }
        let code = atomNamesArray[0] + atomNamesArray[1] + String(order)
        return code
    }
    
}

extension ChemBondType: Hashable {
    public static func == (lhs: ChemBondType, rhs: ChemBondType) -> Bool {
        return
            lhs.atomElements == rhs.atomElements &&
            lhs.order == rhs.order
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(atomElements)
        hasher.combine(order)
    }
}

/**
 Chemical bond between two atoms.
 
 - Designed to be a final class (access through reference) for memory optimization.
 */
public final class ChemBond {
    /**
     The two atoms engaged in the chemical bond.
     */
    public var atoms: Set<Atom> {
        get {
            [atom1, atom2]
        }
        set {
            if newValue.count == 2 {
                let list = Array(newValue)
                atom1 = list[0]
                atom2 = list[1]
            }
        }
    }
    
    /**
     Privately saved for faster determination of the neighbor of an atom.
     */
    private var atom1: Atom
    private var atom2: Atom
    
    /**
     The type of the chemical bond.
     */
    public var type: ChemBondType
    
    /**
     The validity of a bond.
     */
    public var isValid: Bool {
        type.isValid
    }
    
    public init(_ atom1: Atom, _ atom2: Atom, _ bondType: ChemBondType){
        self.type = bondType
        self.atom1 = atom1
        self.atom2 = atom2
    }
    
    /**
     The interatomic distance between the two atoms in the bond.
     */
    public var distance: Double? {
        let atomList = Array(atoms)
        guard atomList.count == 2 else {
            return nil
        }
        return atomDistance(atomList[0], atomList[1])
    }
    
    /**
     Original algorithm to find the neighbor of an atom in the bond via the `atoms`. *(Computationally intensive)*
     */
    public func findNeighbor(_ atom: Atom) -> Atom? {
        var rAtoms = atoms
        rAtoms.remove(atom)
        guard rAtoms.count == 1, let rAtom = rAtoms.first else {
            return nil
        }
        return rAtom
    }
    
    /**
     To find the neighbor via the static private properties `atom1` and `atom2`.
     */
    public func findNeighborViaStatic(_ atom: Atom) -> Atom? {
        if atom1 == atom {
            return atom2
        } else if atom2 == atom {
            return atom1
        } else {
            return nil
        }
    }
    
    /**
     A memoized implementation of dynamic programming for the original algorithm `findNeighbor`.
     */
    public func findNeighborDynProgammed(_ atom: Atom) -> Atom? {
        let nbTuple = AtomNeighborTuple(atoms, atom)
        let neighborInCache = globalCache.atomNeighbors[nbTuple]
        
        if neighborInCache == nil {
            let newNeighbor = findNeighbor(atom)
            if newNeighbor == nil {
                globalCache.atomNeighbors[nbTuple] = (false, atom)
            } else {
                globalCache.atomNeighbors[nbTuple] = (true, newNeighbor!)
            }
            return newNeighbor
        } else {
            if neighborInCache!.0 {
                return neighborInCache!.1
            } else {
                return nil
            }
        }
    }
    
}

extension ChemBond: Hashable {
    public static func == (lhs: ChemBond, rhs: ChemBond) -> Bool {
        return
            lhs.atoms == rhs.atoms &&
            lhs.type == rhs.type
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(atoms)
        hasher.combine(type)
    }
}

/**
 Chemical bond graph constructed by multiple bonds
 */
public struct ChemBondGraph: StrcScoreable {
    /**
     The bonds engaged in this bond graph.
     */
    public var bonds: Set<ChemBond>
    
    public var score: StrcScore?
    
    public init(_ bonds: Set<ChemBond> = Set()){
        self.bonds = bonds
    }
    
    public init(_ bonds: Array<ChemBond> = []) {
        self = .init(Set(bonds))
    }
    
    /**
     The atoms engaged in the bond graph. Calculated from `bonds`.
     */
    public var atoms: Set<Atom> {
        bonds.reduce(Set<Atom>(), { $0.union($1.atoms) })
    }
    
    /**
     The number of bonds that is connected to the atom.
     */
    public func degreeOfAtom(_ atom: Atom) -> Int{
        var deg = 0
        for bond in bonds {
            if bond.findNeighborViaStatic(atom) != nil {
                deg = deg + 1
            }
        }
        return deg
    }
    
    /**
     The adjacencies of atom. Returns the neighboring atoms and connecting bonds.
     */
    public func adjacenciesOfAtom(_ atom: Atom) -> ([Atom], [ChemBond]) {
        var atomList: [Atom] = []
        var bondList: [ChemBond] = []
        atomList.reserveCapacity(atom.valence)
        bondList.reserveCapacity(atom.valence)
        for bond in bonds {
            guard let rAtom = bond.findNeighborViaStatic(atom) else {
                continue
            }
            atomList.append(rAtom)
            bondList.append(bond)
        }
        return (atomList, bondList)
    }

    
    /**
     Find the VSEPR graph based on the given center atom in the bond graph.
     */
    public func findVseprGraph(_ atom: Atom) -> VSEPRGraph {
        let (attached, bonds) = adjacenciesOfAtom(atom)
        return VSEPRGraph(center: atom, attached: attached, bonds: bonds)
    }
    
    /**
     An identifier graph is a hash graph which treats atoms as identifiers (which is equivalent to a labeled graph). The number of identifier graphs should be greater than the number of Lewis structures.
     */
    private func createIdentifierGraph() -> HashGraph {
        var hGraph = HashGraph()
        
        for bond in bonds {
            hGraph.edges.append(HashEdge(points: bond.atoms.map({ HashPoint($0.identifier ?? 0) }), value: bond.type.hashValue))
        }
        
        for atom in atoms {
            hGraph.points.append(HashPoint(atom.identifier ?? 0))
        }
        
        return hGraph
    }
    /**
     An element graph is a hash graph which treats atoms as elements (which is equivalent to a categorized labeled graph). The number of identifier graphs should be less than the number of Lewis structures.
    */
    private func createElementGraph() -> HashGraph {
        var hGraph = HashGraph()
                
        for bond in bonds {
            hGraph.edges.append(HashEdge(points: bond.atoms.map({ HashPoint($0.element.hashValue) }), value: bond.type.hashValue))
        }
        
        for atom in atoms {
            hGraph.points.append(HashPoint(atom.element.hashValue))
        }
        
        return hGraph
    }
    
    /**
     The identifier graph created from the bond graph.
     */
    public var identifierGraph: HashGraph {
        createIdentifierGraph()
    }
    
    /**
     The element graph created from the bond graph.
     */
    public var elementGrpah: HashGraph {
        createElementGraph()
    }
}

extension ChemBondGraph: Hashable {
    public static func == (lhs: ChemBondGraph, rhs: ChemBondGraph) -> Bool {
        return lhs.bonds == rhs.bonds
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(bonds)
    }
}

/**
 A protocol to control the subgraphs of a bond graph.
 */
public protocol SubChemBondGraph {
    /**
     The bonds engaged in this sub bond graph.
     */
    var bonds: [ChemBond] { get set }
}

/**
 A subgraph of the bond graph that centered on one atom for VSEPR analysis. (Not finished)
 
 - TODO: Monitoring changes for `center`, `attached`, and `bonds` for dynamic updating.
 */
public struct VSEPRGraph: SubChemBondGraph {
    
    /**
     The center atom of the graph.
     */
    public var center: Atom
    
    /**
     The atoms attached to the center atom in the graph.
     */
    public var attached: [Atom]
    
    /**
     The bonds engaged in this VSEPR graph.
     */
    public var bonds: [ChemBond]
    
    /**
     The VSEPR type of this graph. Automatically determined based on the information of bonds.
     */
    public var type: ChemConst.VESPRType? {
        return determineType()
    }
    
    /**
     Find the center atom. Automatically determined from the information of bonds. *(Computationally intensive, may be modified later)*
     */
    public func findCenter() -> Atom? {
        guard bonds.count >= 2 else {
            return nil
        }
        let atomList = bonds.flatMap { Array($0.atoms) }
        var centerAtom: Atom?
        for atom in atomList {
            if (atomList.filter { $0 == atom }).count == bonds.count {
                centerAtom = atom
                break
            }
        }
        return centerAtom
    }
    
    /**
     Find the atoms attached to the center atom. *(Computationally intensive, may be modified later)*
     */
    public func findAttached() -> [Atom] {
        return bonds.flatMap({ Array($0.atoms) }).filter { $0 != center }
    }
    
    /**
     The degree of the center atom.
     */
    public var degree: Int {
        return bonds.count
    }
    
    /**
     The valence of the center atom.
     */
    public var valenceAllowed: Int {
        return center.valence
    }
    
    /**
     The valence occupied by the bonds attached to the center atom.
     */
    public var valenceOccupied: Int {
        return bonds.reduce(0, { $0 + $1.type.order })
    }
    
    /**
     The valence available on the center atom.
     */
    public var valenceAvailable: Int {
        return valenceAllowed - valenceOccupied
    }
    
    /**
     To determine if the bond orders are all the same.
     */
    public var bondOrderSymmetric: Bool {
        guard !bonds.isEmpty else {
            return false
        }
        var bondList = bonds
        let fOrder = bondList[0].type.order
        bondList.removeFirst()
        for bond in bondList {
            if bond.type.order != fOrder {
                return false
            }
        }
        return true
    }
    
    /**
     To determine if the neighbors of the atom all are the same element.
     */
    public var neighborSymmetric: Bool {
        guard !attached.isEmpty else {
            return false
        }
        var atomList = attached
        let fElement = atomList[0].element
        atomList.removeFirst()
        for atom in atomList {
            if atom.element != fElement {
                return false
            }
        }
        return true
    }
    
    /**
     Determine if the VESPR graph is both `bondOrderSymmetric` and `neighborSymmetric`.
     */
    public var completelySymmetric: Bool {
        bondOrderSymmetric && neighborSymmetric
    }
    
    // Not available for use yet
    private func completelySymmetricFilter(tolRatio: Double = 0.1) -> Bool {
        guard completelySymmetric else {
            return true
        }
        
        guard bonds.count >= 3 else {
            return true
        }
        
        let angles = bondAnglesInDeg(center: center, attached: attached).map { $0.0 }
        let nonNilAngles = angles.compactMap({ $0 })
        if nonNilAngles.count < angles.count {
            return false
        }
        let avgAngle = nonNilAngles.reduce(0, +) / Double(nonNilAngles.count)
        for angle in nonNilAngles {
            if !((avgAngle * (1 - tolRatio))...(avgAngle * (1 + tolRatio))).contains(angle) {
                return false
            }
        }
        return true
    }
    
    /**
     To determine the VESPR type of the graph.
     */
    private func determineType() -> ChemConst.VESPRType? {
        guard bonds.count >= 2 else {
            return nil
        }
        let numOfLonePairsAndH = 4 - valenceOccupied
        switch (degree, numOfLonePairsAndH) {
        case (2, 0):
            return .ax2e0
        case (2, 1):
            return .ax2e1
        case (2, 2):
            return .ax2e2
        case (2, 3):
            return .ax2e3
        case (3, 0):
            return .ax3e0
        case (3, 1):
            return .ax3e1
        case (3, 2):
            return .ax3e2
        case (4, 0):
            return .ax4e0
        case (4, 1):
            return .ax4e1
        case (4, 2):
            return .ax4e2
        default:
            break
        }
        return nil
    }
    
    /**
     A filter to determine if this VSEPR graph is valid.
     */
    public func filter(tolRatio: Double = 0.1, csTolRatio: Double? = nil, copTolRange: Double = 0.01) -> Bool {
        let sts = filterSTS(tolRatio: tolRatio, csTolRatio: csTolRatio, copTolRange: copTolRange)
        return !sts.map({ $1.isValid }).contains(false)
    }
    
    public func filterSTS(tolRatio: Double = 0.1, csTolRatio: Double? = nil, copTolRange: Double = 0.01) -> [StrcDevTuple] {
        var rList = [StrcDevTuple]()
        
        if (center.valence - valenceOccupied) < 0 {
            rList.append((.valence, StrcDeviation(false, Double(valenceOccupied - center.valence))))
        } else {
            rList.append((.valence, StrcDeviation.success))
        }
        let vType = type
        switch vType {
        case .ax2e0, .ax2e1, .ax2e2, .ax3e0, .ax3e1, .ax4e0:
            var range = 0.0...360.0
            var copRange: ClosedRange<Double>? // Co-planrity range
            switch vType {
            case .ax2e0: // linear
                range = 180.0...180.0
//                range = 170.0...180.0
            case .ax3e0, .ax2e1: // trigonal planar
                range = 120.0...120.0
//                range = 115.0...125.0
                if vType == .ax3e0 {
                    copRange = 0.0...0.05
                }
            case .ax4e0, .ax3e1, .ax2e2: // tetrahedral
//                range = 90...109.5
                range = 90.0...115.0
//                if vType == .ax3e1 {
//                    copRange = 0.4...0.7
//                }
            default:
                break
            }
            
            let baDev = bondAnglesFilterSTS(center: center, attached: attached, range: range, tolRatio: tolRatio)
            rList.append((.bondAngle, baDev))
            
            if degree == 3 && copRange != nil {
                let d3Dev = degreeThreeAtomPlanarDistanceFilterSTS(center: center, attached: attached, range: copRange!, tolLevel: copTolRange)
                rList.append((.coplanarity, d3Dev))
            }
            
//            if !completelySymmetricFilter(tolRatio: csRatio) {
//                return false
//            }
            
        default:
            break
        }
        
        return rList
    }
}

/**
 Structural molecule: a not necessarily meaningful "molecule" with atoms constrained by serveral possible bond graphs
 */
public struct StrcMolecule: StrcScoreable {
    /**
     The atoms in this structural molecule.
     */
    public var atoms: Set<Atom>
    
    /**
     The possible bond graphs to connect the atoms in this structural molecule. Not necessarily unique.
     */
    public var bondGraphs: Set<ChemBondGraph>
    
    public var score: StrcScore?
    
    public init(_ atoms: Set<Atom> = Set(), _ bondGraphs: Set<ChemBondGraph> = Set(), _ score: StrcScore? = nil) {
        self.atoms = atoms
        self.bondGraphs = bondGraphs
        self.score = score
    }
    
    /**
     The number of atoms in this structual molecule.
     */
    public var size: Int {
        return atoms.count
    }
    
    /**
     The center of mass of the molecule
     */
    public var centerOfMass: Vector3D {
        return atoms.centerOfMass
    }
    
    /**
     Add an atom to the molecule.
     */
    public mutating func addAtom(_ atom: Atom){
        atoms.insert(atom)
    }
    
    /**
     Combine two molecules given they are 'atom match' (`~=`) to each other.
     
     - The function effectively joins the bondgraphs of two 'atom match' molecules.
     */
    @discardableResult
    public mutating func combine(_ stMol: StrcMolecule) -> Bool {
        if stMol ~= self {
            bondGraphs.formUnion(stMol.bondGraphs)
            return true
        } else {
            return false
        }
    }
    
    /**
     Return the molecule after the combination of two 'atom match' molecules.
     */
    public func combined(_ stMol: StrcMolecule) -> StrcMolecule? {
        var result = stMol
        if result ~= self {
            result.combine(self)
            return result
        } else {
            return nil
        }
    }
    
    /**
     To determine if the `StrcMolecule` contains an original atom by its identifier.
     */
    public func containsById(_ atom: Atom) -> Bool {
        for a in atoms {
            if a .= atom {
                return true
            }
        }
        return false
    }
    
}

extension StrcMolecule: Hashable {
    public static func == (lhs: StrcMolecule, rhs: StrcMolecule) -> Bool {
        return
            lhs.atoms == rhs.atoms &&
            lhs.bondGraphs == rhs.bondGraphs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(atoms)
        hasher.combine(bondGraphs)
    }
}

infix operator ~=: ComparisonPrecedence
infix operator !~=: ComparisonPrecedence

public extension StrcMolecule {
    /**
     Atom Match
     - Returns true if the two molecules have the same set of atoms.
     */
    static func ~= (lhs: StrcMolecule, rhs: StrcMolecule) -> Bool {
        return
            lhs.atoms == rhs.atoms
    }
    
    /**
     Atom Not Match
     - Returns true if the two molecules does not the same set of atoms.
     */
    static func !~= (lhs: StrcMolecule, rhs: StrcMolecule) -> Bool {
        return !(lhs ~= rhs)
    }
}

/**
 The enumeration of filters used in structure determination.
 */
public enum StrcFilter {
    case minimumBondLength
    case bondTypeLength
    case bondAngle
    case coplanarity
    case valence
    case fatalError
}

/**
 The basic structure of structure deviation, which would be used in the calculation of structure score (STS).
 */
public struct StrcDeviation {
    public var isValid: Bool
    
    public var devInSigma: Double
    
    public init(_ validity: Bool, _ sigma: Double) {
        isValid = validity
        devInSigma = sigma
    }
}

extension StrcDeviation {
    public var inRange: Bool {
        devInSigma.isZero
    }
}

public extension StrcDeviation {
    /**
     Equivalent of simply returning `false`. Contains a deviation of infinity.
     */
    static let failure = StrcDeviation(false, Double.infinity)
    
    /**
     Equivalent of simply returning `true`. Contains a deviation of zero.
     */
    static let success = StrcDeviation(true, 0)
}

public typealias StrcDevTuple = (filter: StrcFilter, dev: StrcDeviation)

/**
 Structure score (STS) is an evaluation of the "goodness" of a `StrcMolecule`. The score would be based on the deviation of the molecule from the four filters.
 */
public struct StrcScore {
    public var baseScore: Double = 100
    
    public var saved: Bool = false {
        didSet(newValue) {
            if _deviations == nil && newValue == true {
                _deviations = [StrcDevTuple]()
            } else if _deviations != nil && newValue == false {
                _deviations = nil
            }
        }
    }
    
    private var _deviations: [StrcDevTuple]?
    
    private var _sScore: Double
    
    public init(base: Double, save: Bool = false){
        baseScore = base
        _sScore = base
        saved = save
    }
}

public extension StrcScore {
    var deviations: [StrcDevTuple]? {
        get {
            _deviations
        }
    }
}

public extension StrcScore {
    /**
     A linear-model determination of simple-deviation.
     */
    static let sBases: [StrcFilter: Double] = [
        // StrcMolecule level
        .minimumBondLength: 100,
        // Inter StrcMolecule-ChemBondGraph level
        .bondTypeLength: 100,
        // ChemBondGraph level
        .bondAngle: 100,
        .coplanarity: 100,
        .valence: 200,
        // Miscellaneous
        .fatalError: Double.infinity
    ]
}

public extension StrcScore {
    /**
     Score determined by simple-deviation.
     */
    var sScore: Double {
        _sScore
    }
}

private extension StrcScore {
    mutating func _sScoreUpdate(dev: StrcDeviation, filter: StrcFilter) {
        if dev.isValid == false {
            _sScore = _sScore - StrcScore.sBases[filter]! * abs(dev.devInSigma)
        }
    }
    
    mutating func _sScoreUpdate(with contents: [StrcDevTuple]) {
        for (filter, dev) in contents {
            _sScoreUpdate(dev: dev, filter: filter)
        }
    }
}

public extension StrcScore {
    var isValid: Bool {
        sScore >= 0
    }
}

public extension StrcScore {
    mutating func append(dev: StrcDeviation, filter: StrcFilter) {
        if saved {
            _deviations!.append((filter, dev))
        }
        _sScoreUpdate(dev: dev, filter: filter)
    }
    
    mutating func append(filter: StrcFilter, dev: StrcDeviation) {
        append(dev: dev, filter: filter)
    }
    
    mutating func append(contentsOf contents: [StrcDevTuple]) {
        if saved {
            _deviations!.append(contentsOf: contents)
        }
        _sScoreUpdate(with: contents)
    }
}

public extension StrcScore {
    static let ultimateSuccess = StrcScore(base: Double.infinity)
    static let ultimateFailure = StrcScore(base: -Double.infinity)
}

public protocol StrcScoreable {
    var score: StrcScore? { get }
}

public extension StrcScoreable {
    var isValid: Bool {
        score?.isValid ?? true
    }
}

// MARK: Tools

/**
 Calculate the distance between two atoms.
 */
public func atomDistance(_ atom1: Atom, _ atom2: Atom) -> Double?{
    guard atom1.rvec != nil && atom2.rvec != nil else {
        return nil
    }
    let dvec = atom1.rvec! - atom2.rvec!
    let d = sqrt(dvec .* dvec)
    return d
}

/**
 Find possible bond types between two atom names
 */
public func possibleBondTypes(_ atomName1: ChemElement, _ atomName2: ChemElement) -> [ChemBondType] {
    var possibleBondTypeList: [ChemBondType] = []
    for order in 1...4 {
        let bond = ChemBondType(atomName1, atomName2, order)
        if bond.validate() {
            possibleBondTypeList.append(bond)
        }
    }
    return possibleBondTypeList
}

/**
 Use cache to implement the memoized dynamic programming for determination of possible bond types between two atoms.
 */
public func possibleBondTypesDynProgrammed(_ atomName1: ChemElement?, _ atomName2: ChemElement?) -> [ChemBondType] {
    guard let element1 = atomName1, let element2 = atomName2 else {
        return []
    }
    let btTuple = [element1, element2]
    var bondTypes = globalCache.possibleBondTypes[[element1, element2]]
    
    if bondTypes == nil {
        bondTypes = possibleBondTypes(element1, element2)
        globalCache.possibleBondTypes[btTuple] = bondTypes!
    }
    
    return bondTypes!
}

/**
 Find the lowest possible bond length between two elements that presented in the constants page.
 */
public func minimumBondLength(_ element1: ChemElement, _ element2: ChemElement) -> Double {
    let possibleBTs = possibleBondTypes(element1, element2)
    return possibleBTs.map({ $0.lengthRangeTuple?.0 ?? 0.0}).min() ?? 0
}

/**
 Use cache to implement the memoized dynamic programming in the determination of minimum bond length between two elements.
 */
public func minimumBondLengthDynProgrammed(_ element1: ChemElement, _ element2: ChemElement) -> Double {
    let elements = [element1, element2]
    guard let len = globalCache.minimumBondLength[elements] else {
        let newLen = minimumBondLength(element1, element2)
        globalCache.minimumBondLength[elements] = newLen
        return newLen
    }
    return len
}

/**
 (D3APD) The distance between a degree-3 atom and the co-plane of its three adjacent atom.
 */
public func degreeThreeAtomPlanarDistance(center: Atom, attached: [Atom]) -> Double? {
    let attachedRVecs = attached.compactMap { $0.rvec }
    guard center.rvec != nil && attachedRVecs.count == 3 else{
        return nil
    }
    let dVec1 = attachedRVecs[0] - attachedRVecs[1]
    let dVec2 = attachedRVecs[0] - attachedRVecs[2]
    let nVec = dVec1 ** dVec2
    let dVec = center.rvec! - attachedRVecs[0]
    
    return abs(dVec.scalarProject(on: nVec))
}

// Bond Angles

/**
 The bond angle of the two bonds of an atom. Takes the two attached atoms as parameter. *(Beta)*
 */
public func bondAngle(center: Atom, attached: [Atom]) -> Measurement<UnitAngle>? {
    guard let theta = bondAngleInDeg(center: center, attached: attached) else {
        return nil
    }
    return Measurement<UnitAngle>(value: theta, unit: UnitAngle.degrees)
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached bonds as parameter. *(Beta)*
 */
public func bondAngle(center: Atom, bonds: [ChemBond]) -> Measurement<UnitAngle>? {
    guard let theta = bondAngleInDeg(center: center, bonds: bonds) else {
        return nil
    }
    return Measurement<UnitAngle>(value: theta, unit: UnitAngle.degrees)
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached atoms as parameter. Returns the angle in degree. Has an option to turn on/off of the memoized dynamic programming (off by default).
 */
public func bondAngleInDeg(center: Atom, attached: [Atom], dynProgammed: Bool = false) -> Double? {
    if dynProgammed {
        guard let baTuple = BondAngleTuple(center, attached: attached) else {
            return nil
        }
        guard let theta = globalCache.bondAngles[baTuple] else {
            guard let newTheta = bondAngleInDegOriginal(center: center, attached: attached) else {
                return nil
            }
            
            globalCache.bondAngles[baTuple] = newTheta
            return newTheta
        }
        return theta
    } else {
        return bondAngleInDegOriginal(center: center, attached: attached)
    }
    
}

/**
 The original implementation of `bondAngleInDeg`.
 */
public func bondAngleInDegOriginal(center: Atom, attached: [Atom]) -> Double? {
    let attachedRVecs = attached.compactMap { $0.rvec }
    guard center.rvec != nil && attachedRVecs.count == 2 else {
        return nil
    }
    let dVec1 = center.rvec! - attachedRVecs[0]
    let dVec2 = center.rvec! - attachedRVecs[1]
    
    return dVec1.angleInDeg(to: dVec2)
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached bonds as parameter. Returns the angle in degree.
 */
public func bondAngleInDeg(center: Atom, bonds: [ChemBond]) -> Double? {
    let attachedMap = bonds.map({ $0.atoms.subtracting([center])})
    let attachedAtoms = attachedMap.reduce(Set<Atom>(), {$0.union($1)})
    return bondAngleInDeg(center: center, attached: Array(attachedAtoms))
}


/**
 The bond angle of any number of bonds of an atom. Returns tuple of angle and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
public func bondAngles(center: Atom, attached: [Atom]) -> [(Measurement<UnitAngle>?, Set<Atom>)] {
    let attachedAtomsList = combinationsDynProgrammed(attached, 2)
    return attachedAtomsList.map { (bondAngle(center: center, attached: Array($0)), $0) }
}

/**
 The bond angle of any number of bonds of an atom. Returns tuple of angle and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
public func bondAngles(center: Atom, bonds: [ChemBond]) -> [(Measurement<UnitAngle>?, Set<ChemBond>)] {
    let attachedAtomsList = combinationsDynProgrammed(bonds, 2)
    return attachedAtomsList.map { (bondAngle(center: center, bonds: Array($0)), $0) }
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached atoms as parameter. Return the value of the angle given provided unit.
 */
public func bondAngle(center: Atom, attached: [Atom], unit: UnitAngle) -> Double? {
    return bondAngle(center: center, attached: attached)?.converted(to: unit).value
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached bonds as parameter. Return the value of the angle given provided unit.
 */
public func bondAngle(center: Atom, bonds: [ChemBond], unit: UnitAngle) -> Double? {
    return bondAngle(center: center, bonds: bonds)?.converted(to: unit).value
}

/**
 The bond angle of any number of bonds of an atom. Returns tuple of the value of the angle given provided unit and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
public func bondAngles(center: Atom, attached: [Atom], unit: UnitAngle) -> [(Double?, Set<Atom>)] {
    let attachedAtomsList = combinationsDynProgrammed(attached, 2)
    return attachedAtomsList.map { (bondAngle(center: center, attached: Array($0), unit: unit), $0) }
}

/**
 The bond angle of any number of bonds of an atom. Returns tuple of the value of the angle given provided unit and the set of the two bonds of the bond angle.
 */
public func bondAngles(center: Atom, bonds: [ChemBond], unit: UnitAngle) -> [(Double?, Set<ChemBond>)] {
    let attachedAtomsList = combinationsDynProgrammed(bonds, 2)
    return attachedAtomsList.map { (bondAngle(center: center, bonds: Array($0), unit: unit), $0) }
}
/**
 The bond angle of any number of bonds of an atom. Returns tuple of the value of the angle in degrees and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
public func bondAnglesInDeg(center: Atom, attached: [Atom]) -> [(Double?, Set<Atom>)] {
    let attachedAtomsList = combinationsDynProgrammed(attached, 2)
    return attachedAtomsList.map { (bondAngleInDeg(center: center, attached: Array($0)), $0) }
}

/**
 The bond angle of any number of bonds of an atom. Returns tuple of the value of the angle in degrees and the set of the two bonds of the bond angle.
 */
public func bondAnglesInDeg(center: Atom, bonds: [ChemBond]) -> [(Double?, Set<ChemBond>)] {
    let attachedAtomsList = combinationsDynProgrammed(bonds, 2)
    return attachedAtomsList.map { (bondAngleInDeg(center: center, bonds: Array($0)), $0) }
}

/**
 Determine the center of a list of point masses.
 
 - Parameter masses: an array of `(Double, Vector3D)` tuples containing the mass as the first element and the position vector as the second element.
 */
public func centerOfPointMasses(_ masses: [(Double, Vector3D)]) -> Vector3D {
    var cmVec = Vector3D()
    var totalMass = 0.0
    for (mass, rvec) in masses {
        totalMass = totalMass + mass
        cmVec = cmVec + mass * rvec
    }
    cmVec = cmVec / totalMass
    return cmVec
}

/**
 Select the farthest atom used by Structure Finder.
 */
public func selectFarthestAtom(from atomList: [Atom]) -> Atom? {
    guard !atomList.isEmpty else {
        print("No atoms in atom list.")
        return nil
    }
    
    guard atomList.filter({ $0.rvec == nil }).isEmpty else {
        print("Contain nil rvecs. Illegal.")
        return nil
    }
    
    let sortedAtoms = atomList.sorted(by: { $0.rvec!.magnitude > $1.rvec!.magnitude })
    let nonZeroAtoms = sortedAtoms.filter { !$0.rvec!.dictVec.contains(0.0) }
    let A1 = nonZeroAtoms.isEmpty ? sortedAtoms[0] : nonZeroAtoms[0]
    return A1
}

// MARK: Filters

/**
 Filtering by bond length with the reference of bond type (bondlength range implemented)
 */
public func bondTypeLengthFilter(_ atom1: Atom, _ atom2: Atom, _ bondType: ChemBondType, _ tolRange: Double = 0.1) -> Bool {
    return bondTypeLengthFilterSTS(atom1, atom2, bondType, tolRange).isValid
}

public func bondTypeLengthFilterSTS(_ atom1: Atom, _ atom2: Atom, _ bondType: ChemBondType, _ tolRange: Double = 0.1) -> StrcDeviation {
    guard let d = atomDistance(atom1, atom2), let length = bondType.lengthRangeTuple else {
        return StrcDeviation.failure
    }
    var dev = 0.0
    if d < length.0 {
        dev = (d - length.0) / tolRange
    } else if d > length.1 {
        dev = (d - length.1) / tolRange
    } else {
        return StrcDeviation.success
    }
    let pass = (abs(dev) <= 1)
    return StrcDeviation(pass, dev)
}

/**
 Filtering by bond length with the reference of bond type (original, deprecated)
 */
public func bondTypeLengthFilterLegacy(_ atom1: Atom, _ atom2: Atom, _ bondType: ChemBondType, _ tolRange: Double = 0.1) -> Bool {
    guard let d = atomDistance(atom1, atom2), let length = bondType.length else {
        return false
    }
    if d < (length - tolRange) || d > (length + tolRange) {
        return false
    }
    else {
        return true
    }
}

/**
 Filtering by bond angle with a given range. Given a list of angles in degrees.
 */
public func bondAnglesFilter(_ angles: [Double?], range: ClosedRange<Double>, tolRatio: Double = 0.1) -> Bool {
    return bondAnglesFilterSTS(angles, range: range, tolRatio: tolRatio).isValid
}

public func bondAnglesFilterSTS(_ angles: [Double?], range: ClosedRange<Double>, tolRatio: Double = 0.1) -> StrcDeviation {
    let lowerBound = tolRatio < 1 ? range.lowerBound * (1 - tolRatio) : 0
    let upperBound = range.upperBound * (1 + tolRatio)
    let tRange: ClosedRange<Double> = lowerBound...upperBound
    let midpoint = (range.lowerBound + range.upperBound) / 2
    let sigma = midpoint * tolRatio
    for theta in angles {
        guard let t = theta else {
            return StrcDeviation.failure
        }
        
        if !tRange.contains(t) && !tRange.contains(360.0 - t) {
            return StrcDeviation(false, (t - midpoint) / sigma)
        }
    }
    return StrcDeviation.success
}

/**
 Filtering by bond angle with a given range. Takes the center atom and attached bonds as parameters.
 */
public func bondAnglesFilter(center aAtom: Atom, bonds: [ChemBond], range: ClosedRange<Double>, tolRatio: Double = 0.1) -> Bool {
    return bondAnglesFilterSTS(center: aAtom, bonds: bonds, range: range, tolRatio: tolRatio).isValid
}

public func bondAnglesFilterSTS(center aAtom: Atom, bonds: [ChemBond], range: ClosedRange<Double>, tolRatio: Double = 0.1) -> StrcDeviation {
    var thetaList = [Double?]()
    switch bonds.count {
    case 2:
        thetaList = [bondAngleInDeg(center: aAtom, bonds: bonds)]
    case 3...:
        thetaList = bondAnglesInDeg(center: aAtom, bonds: bonds).map { $0.0 }
    case 0...:
        return StrcDeviation.success
    default:
        return StrcDeviation.failure
    }
    
    return bondAnglesFilterSTS(thetaList, range: range, tolRatio: tolRatio)
}

/**
 Filtering by bond angle with a given range. Takes the center atom and attached atoms as parameters.
 */
public func bondAnglesFilter(center aAtom: Atom, attached: [Atom], range: ClosedRange<Double>, tolRatio: Double = 0.1) -> Bool {
    return bondAnglesFilterSTS(center: aAtom, attached: attached, range: range, tolRatio: tolRatio).isValid
}

public func bondAnglesFilterSTS(center aAtom: Atom, attached: [Atom], range: ClosedRange<Double>, tolRatio: Double = 0.1) -> StrcDeviation {
    var thetaList = [Double?]()
    switch attached.count {
    case 2:
        thetaList = [bondAngleInDeg(center: aAtom, attached: attached)]
    case 3...:
        thetaList = bondAnglesInDeg(center: aAtom, attached: attached).map { $0.0 }
    case 0...:
        return StrcDeviation.success
    default:
        return StrcDeviation.failure
    }
    
    return bondAnglesFilterSTS(thetaList, range: range, tolRatio: tolRatio)
}

/**
 A filter to filter out the atoms that are too close to the target atom.
 */
public func minimumBondLengthFilter(_ atom1: Atom, _ atom2: Atom, tolRange: Double = 0.01) -> Bool {
    return minimumBondLengthFilterSTS(atom1, atom2, tolRange: tolRange).isValid
}

public func minimumBondLengthFilterSTS(_ atom1: Atom, _ atom2: Atom, tolRange: Double = 0.01) -> StrcDeviation {
    guard let element1 = atom1.element, let element2 = atom2.element else {
        return StrcDeviation.failure
    }
    let atomd = atomDistance(atom1, atom2) ?? 0.0
    let minimumd = minimumBondLengthDynProgrammed(element1, element2)
    let dev = (minimumd - atomd) / tolRange
    return StrcDeviation(dev < 1, dev)
}

/**
 (D3APD filter) A filter to filter out if a degree-3 atom is "out of plane" based on a given range.
 */
public func degreeThreeAtomPlanarDistanceFilter(center: Atom, attached: [Atom], range: ClosedRange<Double>, tolLevel: Double = 0.01) -> Bool {
    return degreeThreeAtomPlanarDistanceFilterSTS(center: center, attached: attached, range: range, tolLevel: tolLevel).isValid
}

public func degreeThreeAtomPlanarDistanceFilterSTS(center: Atom, attached: [Atom], range: ClosedRange<Double>, tolLevel: Double = 0.01) -> StrcDeviation {
    guard let distance = degreeThreeAtomPlanarDistance(center: center, attached: attached) else {
        return StrcDeviation.success
    }
    var dev = 0.0
    if distance < range.lowerBound {
        dev = (distance - range.lowerBound) / tolLevel
    } else if distance > range.upperBound {
        dev = (distance - range.upperBound) / tolLevel
    } else {
        return StrcDeviation.success
    }
    return StrcDeviation(abs(dev) <= 1, dev)
}

// MARK: Constructors

/**
 Molecule constructor for an atom. One atom is compared with a valid structural molecule. The atom will be added to the structural molecule. If the atom is valid to be connected through certain bonds to the structural molecule, that bond will be added to the existing bond graphs. Otherwise, the bond graphs will be empty.
 
 - Parameter stMol: The existing valid structural molecule.
 
 - Parameter atom: The atom to test with the structural molecule `stMol`.
 
 - Parameter tolRange: The tolerance level acting in bond length filters, unit in angstrom.
 
 - Parameter tolRatio: The tolerance ratio acting in bond angle filters. Reference with the VSEPR graph.
 
 */
public func strcMoleculeConstructor(stMol: StrcMolecule, atom: Atom, tolRange: Double = 0.1, tolRatio: Double = 0.1) -> StrcMolecule {
    var mol = stMol
    let bondGraphs = mol.bondGraphs
    
    if mol.size <= 0 {
        mol.addAtom(atom)
    } else {
        mol.bondGraphs.removeAll()
        
        // Step 1: Make sure the new atom is not too close to any of the existing atoms.
        let minimumBDLCheck = stMol.atoms.filter({ !minimumBondLengthFilter(atom, $0, tolRange: tolRange) }).isEmpty
        if !minimumBDLCheck {
            return mol
        }
        
        // Step 2: Find all the possible bond connections between the new atom and any of the existing atoms.
        var possibleBondsCollected: [[ChemBond]] = []
        
        // Step 2.1: Find possible new bond connections of each existing atom.
        for vAtom in stMol.atoms {
            let possibleBts = possibleBondTypesDynProgrammed(vAtom.element, atom.element)
            var possibleBonds = [ChemBond]()
            for bondType in possibleBts {
                if !bondTypeLengthFilter(vAtom, atom, bondType, tolRange) {
                    continue
                } else {
                    let pBond = ChemBond(vAtom, atom, bondType)
                    possibleBonds.append(pBond)
                }
            }
            if !possibleBonds.isEmpty {
                possibleBondsCollected.append(possibleBonds)
            }
        }
        
        // Step 2.2: Find the Cartesian product of the collected possible bonds.
        if possibleBondsCollected.isEmpty {
            return mol
        }
        
        // Step 3: Perform VSEPR filter on each of the possible Cartesian combination of the bonds.
        mol.addAtom(atom)
        
        for pBonds in possibleBondsCollected.cartesianProduct() {
            if stMol.size == 1 {
                mol.bondGraphs.insert(ChemBondGraph(pBonds))
            } else if stMol.size > 1 {
                outer: for bondGraph in bondGraphs {
                    var pBondGraph = bondGraph
                    pBondGraph.bonds.formUnion(pBonds)
                    for bAtom in mol.atoms {
                        let vseprGraph = pBondGraph.findVseprGraph(bAtom)
                        if !vseprGraph.filter(tolRatio: tolRatio, copTolRange: tolRange) {
                            continue outer
                        }
                    }
                    mol.bondGraphs.insert(pBondGraph)
                }
            }
        }
    }
    return mol
}

public func strcMoleculeConstructorSTS(stMol: StrcMolecule, atom: Atom, tolRange: Double, tolRatio: Double = 0.1, baseScore: Double = 100) -> StrcMolecule {
    var mol = stMol
    let bondGraphs = mol.bondGraphs
    
    if mol.size <= 0 {
        mol.addAtom(atom)
    } else {
        mol.bondGraphs.removeAll()
        
        if mol.score == nil {
            mol.score = StrcScore(base: baseScore)
        }
        
        // Step 1: Make sure the new atom is not too close to any of the existing atoms.
        for sAtom in stMol.atoms {
            let mStDev = minimumBondLengthFilterSTS(atom, sAtom, tolRange: tolRange)
            mol.score!.append(dev: mStDev, filter: .minimumBondLength)
            if !mol.isValid {
                return mol
            }
        }
        
        // Step 2: Find all the possible bond connections between the new atom and any of the existing atoms.
        var possibleBondsCollected: [[(ChemBond, StrcDeviation)]] = []
        
        // Step 2.1: Find possible new bond connections of each existing atom.
        for vAtom in stMol.atoms {
            let possibleBts = possibleBondTypesDynProgrammed(vAtom.element, atom.element)
            var possibleBonds = [(ChemBond, StrcDeviation)]()
            for bondType in possibleBts {
                let bStDev = bondTypeLengthFilterSTS(vAtom, atom, bondType, tolRange)
                var intScore = mol.score!
                intScore.append(dev: bStDev, filter: .bondTypeLength)
                if !intScore.isValid {
                    continue
                } else {
                    let pBond = ChemBond(vAtom, atom, bondType)
                    possibleBonds.append((pBond, bStDev))
                }
            }
            if !possibleBonds.isEmpty {
                possibleBondsCollected.append(possibleBonds)
            }
        }
        
        // Step 2.2: Find the Cartesian product of the collected possible bonds.
        if possibleBondsCollected.isEmpty {
            return mol
        }
        
        // Step 3: Perform VSEPR filter on each of the possible Cartesian combination of the bonds.
        mol.addAtom(atom)
        
        for pBondDevCombo in possibleBondsCollected.cartesianProduct() {
            let (pBonds, pDevs) = pBondDevCombo.reduce(into: ([ChemBond](), [StrcDevTuple]()), {
                $0.0.append($1.0)
                $0.1.append((.bondTypeLength, $1.1))
            })
            if stMol.size == 1 {
                var newBondGraph = ChemBondGraph(pBonds)
                newBondGraph.score = StrcScore(base: 100)
                newBondGraph.score!.append(contentsOf: pDevs)
                if newBondGraph.isValid {
                    mol.bondGraphs.insert(newBondGraph)
                }
            } else if stMol.size > 1 {
                outer: for bondGraph in bondGraphs {
                    var pBondGraph = bondGraph
                    if pBondGraph.score == nil {
                        pBondGraph.score = StrcScore(base: 100)
                    }
                    var intScore = pBondGraph.score!
                    intScore.append(contentsOf: pDevs)
                    
                    guard intScore.isValid else {
                        continue outer
                    }
                    
                    pBondGraph.score = intScore
                    pBondGraph.bonds.formUnion(pBonds)
                    for bAtom in mol.atoms {
                        let vseprGraph = pBondGraph.findVseprGraph(bAtom)
                        let vStDevs = vseprGraph.filterSTS(tolRatio: tolRatio, copTolRange: tolRange)
                        pBondGraph.score!.append(contentsOf: vStDevs)
                        if !pBondGraph.isValid {
                            continue outer
                        }
                    }
                    mol.bondGraphs.insert(pBondGraph)
                }
            }
        }
    }
    
    return mol
}

/**
 The recursion constructor. It takes a test atom and compared it with a valid structrual molecule. It will return the possible structural molecules as the atom and the molecule join together.
 */
public func rcsConstructor(atom: Atom, stMol: StrcMolecule, tolRange: Double = 0.1, tolRatio: Double = 0.1, testMode: Bool = false) -> [StrcMolecule] {
    let possibleAtoms = testMode ? [atom] : atom.possibles
    var possibleSMList: [StrcMolecule] = []
    
    for pAtom in possibleAtoms {
        // To be STS-ize
        let sMol = strcMoleculeConstructorSTS(stMol: stMol, atom: pAtom, tolRange: tolRange, tolRatio: tolRatio)
        
        if !sMol.bondGraphs.isEmpty {
            possibleSMList.append(sMol)
        }
    }
    return possibleSMList
}

/**
 The recursion action to perform recursion. *(Currently deprecated)*
 
 - TODO: Optimize with tail recursion.
 */
public func rcsAction(rAtoms: [Atom], stMolList mList: [StrcMolecule], tolRange: Double = 0.1, tolRatio: Double = 0.1, possibleList pList: inout [StrcMolecule], trueMol: StrcMolecule? = nil) {
    if rAtoms.isEmpty {
        for stMol in mList {
            if pList.filter({ $0 == stMol }).isEmpty {
                let saList = pList.filter { $0 ~= stMol }
                if saList.isEmpty {
                    pList.append(stMol)
                    print("Current possible results: \(pList.count)", terminator: "")
                    if trueMol != nil && trueMol!.atoms == stMol.atoms {
                        print("     !!## <The correct structure> has been found.")
                    } else {
                        print()
                    }
                } else {
                    let daList = pList.filter { !saList.contains($0) }
                    let newStMol: StrcMolecule = saList.reduce(stMol, { $0.combined($1) ?? $0 })
                    pList = daList + [newStMol]
                    
                    print("Current possible results: \(pList.count)", terminator: "")
                    print("     ## Duplicated")
                }
            }
        }
    } else {
        for stMol in mList {
            for rAtom in rAtoms {
                let rcsTuple = RcsConstructorTuple(atom: rAtom, stMol: stMol)
                if globalCache.rcsConstructorCache.contains(rcsTuple) {
                    continue
                } else {
                    globalCache.rcsConstructorCache.insert(rcsTuple)
                }
                let newMList = rcsConstructor(atom: rAtom, stMol: stMol, tolRange: tolRange, tolRatio: tolRatio)
                if !newMList.isEmpty {
                    let newRAtoms = rAtoms.filter({$0 != rAtom})
                    rcsAction(rAtoms: newRAtoms, stMolList: newMList, tolRange: tolRange, tolRatio: tolRatio, possibleList: &pList, trueMol: trueMol)
                }
            }
        }
    }
}

/**
 The iteration version of the `rcsAction` for faster and clearer computations. Memoized dynamic progamming is implemented for utilization.
 */
public func rcsActionDynProgrammed(rAtoms: [Atom], stMolList mList: [StrcMolecule], tolRange: Double = 0.01, tolRatio: Double = 0.1, trueMol: StrcMolecule? = nil, testMode: Bool = false) -> [StrcMolecule] {
    guard !rAtoms.isEmpty else {
        return []
    }
    
    let rCount = rAtoms.count
    
    var mDynDict: [Int: [Set<Atom>: Array<StrcMolecule>]] = [Int: [Set<Atom>: Array<StrcMolecule>]]()
    
    for i in 0...rCount {
        mDynDict[i] = [:]
    }
    
    func addStMolToMDynDict(_ j: Int, _ stMol: StrcMolecule) {
        if mDynDict[j]![stMol.atoms] == nil {
            mDynDict[j]![stMol.atoms] = [stMol]
        } else {
            mDynDict[j]![stMol.atoms]!.append(stMol)
        }
    }
    
    
    for stMol in mList {
        addStMolToMDynDict(0, stMol)
    }
    
    func loopDisplayString(_ j1: Int, _ j2: Int, _ tIJ: Date) -> String {
        let timeTaken = String(-(Double(tIJ.timeIntervalSinceNow).rounded(digitsAfterDecimal: 1))) + "s"
        return "Atoms: \(toPrintWithSpace(j1 + 1, 4)) Int. possibles: \(toPrintWithSpace(mDynDict[j2 + 1]!.count, 9)) Time: \(toPrintWithSpace(timeTaken, 10)) "
    }
    
    print(loopDisplayString(0, -1, Date()))
    
    for j in 0...(rCount - 1) {
        let tIJ = Date()
        let previousCount = mDynDict[j]!.count
        for (i, (_, stMols)) in mDynDict[j]!.enumerated() {
            if mDynDict[j] != nil {
                mDynDict[j] = nil
            }
            let percentage = i * 100 / previousCount
            for stMol in stMols {
                let rList = rAtoms.filter { !stMol.containsById($0) }
                for rAtom in rList {
                    let newMList = rcsConstructor(atom: rAtom, stMol: stMol, tolRange: tolRange, tolRatio: tolRatio, testMode: testMode)
                    
                    for newStMol in newMList {
                        if globalCache.stMolMatched.0.contains(newStMol.atoms) {
                            globalCache.stMolMatched.0.remove(newStMol.atoms)
                            globalCache.stMolMatched.1.insert(newStMol.atoms)
                        } else if globalCache.stMolMatched.1.contains(newStMol.atoms) {
                            // Do nothing
                        } else {
                            globalCache.stMolMatched.0.insert(newStMol.atoms)
                        }
                        
                        addStMolToMDynDict(j + 1, newStMol)
                    }
                    
                    
                    #if DEBUG
                    #else
                    printStringInLine(loopDisplayString(j + 1, j, tIJ) + "Calculating (\(percentage)%)")
                    #endif
                }
            }
        }
        
        let dedCount = globalCache.stMolMatched.1.count
        for (i, atoms) in globalCache.stMolMatched.1.enumerated() {
            let saList = mDynDict[j + 1]![atoms]
            let percentage = i * 100 / dedCount
            
            guard saList != nil && saList!.isEmpty == false else {
                continue
            }
            let combinedStMol: StrcMolecule = saList!.reduce(StrcMolecule(atoms), { $0.combined($1) ?? $0 })
            mDynDict[j + 1]![atoms] = [combinedStMol]

            #if DEBUG
            #else
            printStringInLine(loopDisplayString(j + 1, j, tIJ) + "Deduplicating (\(percentage)%)")
            #endif
        }
        
        print(toPrintWithSpace(loopDisplayString(j + 1, j, tIJ), 79))
        
        globalCache.stMolMatched = ([], [])
    }
    
    let result = mDynDict[rCount]!.flatMap({ $0.value })
    
    return result
}

// MARK: Extensions

public extension Array where Element == Atom {
    /**
     Extension of Atom array to be selected by name
     */
    func select(byName name: String) -> [Atom] {
        return filter({$0.name == name})
    }
    
    /**
     Extension of Atom array to be selected by element
     */
    func select(byElement element: ChemElement) -> [Atom] {
        return filter({$0.element == element})
    }
    
    /**
     Extension of Atom array to be removed by name
     */
    func removed(byName name: String) -> [Atom] {
        return filter({$0.name != name})
    }
    
    /**
     Extension of Atom array to be removed by element
     */
    func removed(byElement element: ChemElement) -> [Atom] {
        return filter({$0.element != element})
    }
    
    /**
     Extension of Atom array to remove atoms by name
     */
    mutating func remove(byName name: String) {
        self = removed(byName: name)
    }
    
    /**
     Extension of Atom array to remove atoms by element
     */
    mutating func remove(byElement element: ChemElement) {
        self = removed(byElement: element)
    }
    
    /**
     Extension of Atom array to be removed by a specific atom.
     */
    func removed(_ atom: Atom) -> [Atom] {
        return filter({$0 != atom})
    }
    
    /**
     Extension of Atom array to remove a specific atom.
     */
    mutating func remove(_ atom: Atom) {
        self = removed(atom)
    }
    
    /**
     Trim down the position vectors of all the atoms in the array.
     */
    @discardableResult
    mutating func trimDownRVecs(level trimLevel: Double = 0.005) -> [Bool] {
        return self.indices.map({self[$0].trimDownRVec(level: trimLevel)})
    }
    
    /**
     Round the position vectors of all the atoms in the array.
     */
    @discardableResult
    mutating func roundRVecs(digitsAfterDecimal digits: Int) -> [Bool] {
        return self.indices.map({self[$0].roundRVec(digitsAfterDecimal: digits)})
    }
}

public extension Collection where Iterator.Element == Atom {
    /**
     Possible atoms after resigning
     */
    var possibles: [Atom] {
        var possibleList: [Atom] = []
        for atom in self {
            possibleList.append(contentsOf: atom.possibles)
        }
        return possibleList
    }
    
    /**
     The center of mass of several atoms
     */
    var centerOfMass: Vector3D {
        let masses: [(Double, Vector3D)] = self.map({ ($0.atomicMass ?? 0.0, $0.rvec ?? Vector3D()) })
        return centerOfPointMasses(masses)
    }
    
    /**
     The total atomic mass of the atoms. (Unit in amu)
     */
    var totalAtomicMass: Double {
        self.reduce(0.0, { $0 + ($1.atomicMass ?? 0.0) })
    }
    
    /**
     Set all the mass numbers in the array to `nil`.
     */
    mutating func clearMassNumbers() {
        for i in self.indices {
            self[i].massNumber = nil
        }
    }
    
   /**
    Set the mass number of all the atoms in the array with a given closure.
    */
   mutating func setMassNumber(with selectFunc: (Atom) -> Int?) {
       for i in self.indices {
           self[i].massNumber = selectFunc(self[i])
       }
   }
    
    /**
     Set the mass number of each atom in the array to their most common isotope.
     */
    mutating func setMassNumbersToMostCommon() {
        setMassNumber(with: { $0.element?.mostCommonMassNumber })
    }
    
    /**
     Set the mass number of each atom in the array to their second most common isotope.
     */
    mutating func setMassNumbersToSecondCommon() {
        setMassNumber(with: { $0.element?.secondCommonMassNumber })
    }
}

public extension Vector3D {
    /**
     Re-sign the vector based on |x|, |y|, and |z|.
     */
    func resign() -> [Vector3D] {
        var possibleList: [Vector3D] = []
        let signList = [[1,1,1], [1,1,-1], [1,-1,1], [1,-1,-1], [-1,1,1], [-1,1,-1], [-1,-1,1], [-1,-1,-1]]
        for sign in signList {
            var newDict: [Double] = [0,0,0]
            for i in [0,1,2] {
                newDict[i] = dictVec[i] * Double(sign[i])
            }
            let newRVec = Vector3D(newDict)
            possibleList.append(newRVec)
        }
        possibleList = Array(Set(possibleList)) // Remove duplicates
        return possibleList
    }
}
