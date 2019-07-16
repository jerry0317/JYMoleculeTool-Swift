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

// TODO: Implement Copy-on-write

extension Vector3D {
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

/**
 Atom
 
 - Designed to be a final class (access through reference) for memory optimization.
 */
final class Atom {
    /**
     The name of the atom.
     */
    var name: String {
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
    var element: ChemElement?
    
    /**
     The position vector of the atom.
     */
    var rvec: Vector3D?
    
    /**
     The optional identifier of the atom to trace it down after making the eight possible atoms from re-sigining. Does not effect the hash value.
     */
    var identifier: Int?
    
    init(_ name: String, _ rvec: Vector3D? = nil, _ identifier: Int? = nil){
        self.element = ChemElement(rawValue: name)
        self.rvec = rvec
        self.identifier = identifier
    }
    
    init(_ element: ChemElement?, _ rvec: Vector3D? = nil, _ identifier: Int? = nil){
        self.element = element
        self.rvec = rvec
        self.identifier = identifier
    }
    
    /**
     Possible atoms after re-signing it.
     */
    var possibles: [Atom] {
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
            return possibleRvecList.map { Atom(element, $0, identifier) }
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
    var valence: Int {
        guard let e = element else {
            return 0
        }
        return ChemConst.valences[e] ?? 0
    }
    
    /**
     Trim down the component of the position vector of an atom to zero if the absolute value of that component is less than the trim level.
     */
    @discardableResult
    func trimDownRVec(level trimLevel: Double = 0.01) -> Bool {
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
    func roundRVec(digitsAfterDecimal digit: Int) -> Bool {
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
    func setIdentifier() {
        var hasher = Hasher()
        hasher.combine(element)
        hasher.combine(rvec)
        identifier = hasher.finalize()
    }
}

extension Atom: Hashable {
    static func == (lhs: Atom, rhs: Atom) -> Bool {
        return
            lhs.element == rhs.element &&
            lhs.rvec == rhs.rvec
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(element)
        hasher.combine(rvec)
    }
}

infix operator .=: ComparisonPrecedence
extension Atom {
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
final class ChemBondType {
    /**
     The names of the two atoms in the chemical bond.
     */
    var atomNames: Array<String> {
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
    var atomElements: Set<ChemElement>
    
    /**
     The **array** of elements of the two atoms in the chemical bond. Not accessible from outside.
     */
    private var atomElementArray: [ChemElement] {
        return Array(atomElements)
    }

    /**
     The order of the bond.
     */
    var order: Int
    
    init(_ atom1: String, _ atom2: String, _ bondOrder: Int = 1){
        self.atomElements = []
        self.order = bondOrder
        self.atomNames = [atom1, atom2]
    }
    
    init(_ element1: ChemElement, _ element2: ChemElement, _ bondOrder: Int = 1){
        self.atomElements = [element1, element2]
        self.order = bondOrder
    }
    
    /**
     The bond code for the bond. For example, the single carbon-carbon bond is denoted as .CC1.
     */
    var bdCode: BondCode? {
        return findBdCodeDynProgrammed()
    }
    
    /**
     The bond length of this bond type.
     */
    var length: Double? {
        guard let bd = bdCode else {
            return nil
        }
        return bondLengths[bd]
    }
    
    /**
     The dictionary storing the known bond lengths.
     */
    private var bondLengths: [BondCode: Double] {
        return ChemConst.bondLengths
    }
    
    /**
     Tells if a bond type is valid.
     */
    func validate() -> Bool{
        return bdCode != nil
    }
    
    /**
     Use cache to implement the memoized dynamic programming to find the bond code of the type.
     */
    func findBdCodeDynProgrammed() -> BondCode? {
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
    func findBdCode() -> BondCode? {
        return BondCode(rawValue: findBdCodeString())
    }
    
    /**
     Find the string of the bond code of the bond type.
     */
    func findBdCodeString() -> String {
        var atomNamesArray = atomNames
        if atomNamesArray[0] > atomNamesArray[1] {
            atomNamesArray.swapAt(0, 1)
        }
        let code = atomNamesArray[0] + atomNamesArray[1] + String(order)
        return code
    }
    
}

extension ChemBondType: Hashable {
    static func == (lhs: ChemBondType, rhs: ChemBondType) -> Bool {
        return
            lhs.atomElements == rhs.atomElements &&
            lhs.order == rhs.order
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(atomElements)
        hasher.combine(order)
    }
}

/**
 Chemical bond between two atoms.
 
 - Designed to be a final class (access through reference) for memory optimization.
 */
final class ChemBond {
    /**
     The atoms engaged in the chemical bond.
     */
    var atoms: Set<Atom>
    
    /**
     Privately saved for faster determination of the neighbor of an atom.
     */
    private var atom1: Atom
    private var atom2: Atom
    
    /**
     The type of the chemical bond.
     */
    var type: ChemBondType
    
    init(_ atom1: Atom, _ atom2: Atom, _ bondType: ChemBondType){
        self.atoms = [atom1, atom2]
        self.type = bondType
        self.atom1 = atom1
        self.atom2 = atom2
    }
    
    /**
     The interatomic distance between the two atoms in the bond.
     */
    var distance: Double? {
        let atomList = Array(atoms)
        guard atomList.count == 2 else {
            return nil
        }
        return atomDistance(atomList[0], atomList[1])
    }
    
    /**
     Original algorithm to find the neighbor of an atom in the bond via the `atoms`. *(Computationally intensive)*
     */
    func findNeighbor(_ atom: Atom) -> Atom? {
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
    func findNeighborViaStatic(_ atom: Atom) -> Atom? {
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
    func findNeighborDynProgammed(_ atom: Atom) -> Atom? {
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
    static func == (lhs: ChemBond, rhs: ChemBond) -> Bool {
        return
            lhs.atoms == rhs.atoms &&
            lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(atoms)
        hasher.combine(type)
    }
}

/**
 Chemical bond graph constructed by multiple bonds
 */
struct ChemBondGraph {
    /**
     The bonds engaged in this bond graph.
     */
    var bonds: Set<ChemBond>
    
    init(_ bonds: Set<ChemBond> = Set()){
        self.bonds = bonds
    }
    
    /**
     The number of bonds that is connected to the atom.
     */
    func degreeOfAtom(_ atom: Atom) -> Int{
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
    func adjacenciesOfAtom(_ atom: Atom) -> ([Atom], [ChemBond]) {
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
    func findVseprGraph(_ atom: Atom) -> VSEPRGraph {
        let (attached, bonds) = adjacenciesOfAtom(atom)
        return VSEPRGraph(center: atom, attached: attached, bonds: bonds)
    }
}

extension ChemBondGraph: Hashable {
    static func == (lhs: ChemBondGraph, rhs: ChemBondGraph) -> Bool {
        return lhs.bonds == rhs.bonds
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bonds)
    }
}

/**
 A protocol to control the subgraphs of a bond graph.
 */
protocol SubChemBondGraph {
    /**
     The bonds engaged in this sub bond graph.
     */
    var bonds: [ChemBond] { get set }
}

/**
 A subgraph of the bond graph that centered on one atom for VSEPR analysis. (Not finished)
 
 - TODO: Monitoring changes for `center`, `attached`, and `bonds` for dynamic updating.
 */
struct VSEPRGraph: SubChemBondGraph {
    
    /**
     The center atom of the graph.
     */
    var center: Atom
    
    /**
     The atoms attached to the center atom in the graph.
     */
    var attached: [Atom]
    
    /**
     The bonds engaged in this VSEPR graph.
     */
    var bonds: [ChemBond]
    
    /**
     The VSEPR type of this graph. Automatically determined based on the information of bonds.
     */
    var type: ChemConst.VESPRType? {
        return determineType()
    }
    
    /**
     Find the center atom. Automatically determined from the information of bonds. *(Computationally intensive, may be modified later)*
     */
    func findCenter() -> Atom? {
        guard bonds.count >= 2 else {
            return nil
        }
        let atomList = bonds.flatMap { Array($0.atoms) }
        var centerAtom: Atom? = nil
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
    func findAttached() -> [Atom] {
        return bonds.flatMap({ Array($0.atoms) }).filter { $0 != center }
    }
    
    /**
     The degree of the center atom.
     */
    var degree: Int {
        return bonds.count
    }
    
    /**
     The valence of the center atom.
     */
    var valenceAllowed: Int {
        return center.valence
    }
    
    /**
     The valence occupied by the bonds attached to the center atom.
     */
    var valenceOccupied: Int {
        return bonds.reduce(0, { $0 + $1.type.order })
    }
    
    /**
     The valence available on the center atom.
     */
    var valenceAvailable: Int {
        return valenceAllowed - valenceOccupied
    }
    
    /**
     To determine if the bond orders are all the same.
     */
    var completelySymmetric: Bool {
        var bondList = Array(bonds)
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
    func filter(bondAngleTolRatio tolRatio: Double = 0.1) -> Bool {
        guard (center.valence - valenceOccupied) >= 0 else {
            return false
        }
        let vType = type
        switch vType {
        case .ax2e0, .ax2e1, .ax2e2, .ax3e0, .ax3e1, .ax4e0:
            var range = 0.0...0.0
            switch vType {
            case .ax2e0: // linear
                range = 180.0...180.0
            case .ax3e0, .ax2e1: // trigonal planar
                range = 120.0...120.0
            case .ax4e0, .ax3e1, .ax2e2: // tetrahedral
                range = 90...109.5
            default:
                break
            }
            return bondAnglesFilter(center: center, attached: attached, range: range)
        default:
            break
        }
        return true
    }
}

/**
 Structural molecule: a not necessarily meaningful "molecule" with atoms constrained by serveral possible bond graphs
 */
struct StrcMolecule {
    /**
     The atoms in this structural molecule.
     */
    var atoms: Set<Atom>
    
    /**
     The possible bond graphs to connect the atoms in this structural molecule. Not necessarily unique.
     */
    var bondGraphs: Set<ChemBondGraph>
    
    init(_ atoms: Set<Atom> = Set(), _ bondGraphs: Set<ChemBondGraph> = Set()) {
        self.atoms = atoms
        self.bondGraphs = bondGraphs
    }
    
    /**
     The number of atoms in this structual molecule.
     */
    var size: Int {
        return atoms.count
    }
    
    /**
     The center of mass of the molecule
     */
    var centerOfMass: Vector3D {
        return atoms.centerOfMass
    }
    
    /**
     Add an atom to the molecule.
     */
    mutating func addAtom(_ atom: Atom){
        atoms.insert(atom)
    }
    
    /**
     Combine two molecules given they are 'atom match' (`~=`) to each other.
     
     - The function effectively joins the bondgraphs of two 'atom match' molecules.
     */
    @discardableResult
    mutating func combine(_ stMol: StrcMolecule) -> Bool {
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
    func combined(_ stMol: StrcMolecule) -> StrcMolecule? {
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
    func containsById(_ atom: Atom) -> Bool {
        for a in atoms {
            if a .= atom {
                return true
            }
        }
        return false
    }
}

extension StrcMolecule: Hashable {
    static func == (lhs: StrcMolecule, rhs: StrcMolecule) -> Bool {
        return
            lhs.atoms == rhs.atoms &&
            lhs.bondGraphs == rhs.bondGraphs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(atoms)
        hasher.combine(bondGraphs)
    }
}

infix operator ~=: ComparisonPrecedence
infix operator !~=: ComparisonPrecedence

extension StrcMolecule {
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
 Calculate the distance between two atoms
 */
func atomDistance(_ atom1: Atom, _ atom2: Atom) -> Double?{
    guard atom1.rvec != nil && atom2.rvec != nil else {
        return nil
    }
    let dvec = atom1.rvec! - atom2.rvec!
    let d = sqrt(dvec .* dvec)
    return d
}

/**
 Filtering by bond length with the reference of bond type
 */
func bondTypeLengthFilter(_ atom1: Atom, _ atom2: Atom, _ bondType: ChemBondType, _ tolRange: Double = 0.1) -> Bool {
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
 Find possible bond types between two atom names
 */
func possibleBondTypes(_ atomName1: ChemElement, _ atomName2: ChemElement) -> [ChemBondType] {
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
func possibleBondTypesDynProgrammed(_ atomName1: ChemElement?, _ atomName2: ChemElement?) -> [ChemBondType] {
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
 Filtering by bond angle with a given range. Given a list of angles in degrees.
 */
func bondAnglesFilter(_ angles: [Double?], range: ClosedRange<Double>, tolRatio: Double = 0.1) -> Bool {
    let lowerBound = range.lowerBound * (1 - tolRatio)
    let upperBound = range.upperBound * (1 + tolRatio)
    let tRange: ClosedRange<Double> = lowerBound...upperBound
    for theta in angles {
        if theta == nil || !tRange.contains(theta!) {
            return false
        }
    }
    return true
}

/**
 Filtering by bond angle with a given range. Takes the center atom and attached bonds as parameters.
 */
func bondAnglesFilter(center aAtom: Atom, bonds: [ChemBond], range: ClosedRange<Double>, tolRatio: Double = 0.1) -> Bool {
    var thetaList: [Double?] = []
    if bonds.count == 2 {
        thetaList = [bondAngleInDeg(center: aAtom, bonds: bonds)]
    } else if bonds.count >= 2 {
        let rList = bondAnglesInDeg(center: aAtom, bonds: bonds)
        thetaList = rList.map { $0.0 }
    } else if bonds.count >= 0{
        return true
    } else {
        return false
    }
    
    return bondAnglesFilter(thetaList, range: range, tolRatio: tolRatio)
}

/**
 Filtering by bond angle with a given range. Takes the center atom and attached atoms as parameters.
 */
func bondAnglesFilter(center aAtom: Atom, attached: [Atom], range: ClosedRange<Double>, tolRatio: Double = 0.1) -> Bool {
    var thetaList: [Double?] = []
    if attached.count == 2 {
        thetaList = [bondAngleInDeg(center: aAtom, attached: attached)]
    } else if attached.count >= 2 {
        let rList = bondAnglesInDeg(center: aAtom, attached: attached)
        thetaList = rList.map { $0.0 }
    } else if attached.count >= 0{
        return true
    } else {
        return false
    }
    
    return bondAnglesFilter(thetaList, range: range, tolRatio: tolRatio)
}

/**
 Molecule constructor for an atom. One atom is compared with a valid structural molecule. The atom will be added to the structural molecule. If the atom is valid to be connected through certain bonds to the structural molecule, that bond will be added to the existing bond graphs. Otherwise, the bond graphs will be empty.
 
 - Parameter stMol: The existing valid structural molecule.
 
 - Parameter atom: The atom to test with the structural molecule `stMol`.
 
 - Parameter tolRange: The tolerance level acting in bond length filters, unit in angstrom.
 
 - Parameter tolRatio: The tolerance ratio acting in bond angle filters. Reference with the VSEPR graph.
 
 */
func strcMoleculeConstructor(stMol: StrcMolecule, atom: Atom, tolRange: Double = 0.1, tolRatio: Double = 0.1) -> StrcMolecule {
    var mol = stMol
    let bondGraphs = mol.bondGraphs
    
    var atomAdded = false
    
    if mol.size <= 0 {
        mol.addAtom(atom)
    }
    else {
        mol.bondGraphs.removeAll()
        for vAtom in stMol.atoms {
            let possibleBts = possibleBondTypesDynProgrammed(vAtom.element, atom.element)
            for bondType in possibleBts {
                guard bondTypeLengthFilter(vAtom, atom, bondType, tolRange) else {
                    continue
                }
                
                let vRemainingAtoms = stMol.atoms.filter({$0 != vAtom})
                var dPass = true
                for vRAtom in vRemainingAtoms {
                    guard let d: Double = atomDistance(vRAtom, atom) else {
                        dPass = false
                        break
                    }
                    if d < (bondType.length! - tolRange) {
                        dPass = false
                        break
                    }
                }
                if dPass {
                    let pBond = ChemBond(vAtom, atom, bondType)
                    if !atomAdded {
                        mol.addAtom(atom)
                        atomAdded = true
                    }
                    if stMol.size == 1 {
                        mol.bondGraphs.insert(ChemBondGraph(Set([pBond])))
                    } else if stMol.size > 1 {
                        for bondGraph in bondGraphs {
                            var pBondGraph = bondGraph
                            pBondGraph.bonds.insert(pBond)
                            var bPass = true
                            for bAtom in stMol.atoms {
                                if pBondGraph.degreeOfAtom(bAtom) >= 2 {
                                    let vseprGraph = pBondGraph.findVseprGraph(bAtom)
                                    if !vseprGraph.filter(bondAngleTolRatio: tolRatio) {
                                        bPass = false
                                        break
                                    }
                                }
                            }
                            if bPass {
                                mol.bondGraphs.insert(pBondGraph)
                            }
                        }
                    }
                }
            }
        }
    }
    return mol
}

/**
 The recursion constructor. It takes a test atom and compared it with a valid structrual molecule. It will return the possible structural molecules as the atom and the molecule join together.
 */
func rcsConstructor(atom: Atom, stMol: StrcMolecule, tolRange: Double = 0.1, tolRatio: Double = 0.1) -> [StrcMolecule] {
    let possibleAtoms = atom.possibles
    var possibleSMList: [StrcMolecule] = []
    
    for pAtom in possibleAtoms {
        let sMol = strcMoleculeConstructor(stMol: stMol, atom: pAtom, tolRange: tolRange, tolRatio: tolRatio)
        
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
func rcsAction(rAtoms: [Atom], stMolList mList: [StrcMolecule], tolRange: Double = 0.1, tolRatio: Double = 0.1, possibleList pList: inout [StrcMolecule], trueMol: StrcMolecule? = nil) {
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
func rcsActionDynProgrammed(rAtoms: [Atom], stMolList mList: [StrcMolecule], tolRange: Double = 0.1, tolRatio: Double = 0.1, trueMol: StrcMolecule? = nil) -> [StrcMolecule] {
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
        return "Atoms: \(toPrintWithSpace(j1 + 1, 4)) Interm. possibles: \(toPrintWithSpace(mDynDict[j2 + 1]!.count, 9)) Time: \(toPrintWithSpace(timeTaken, 10)) "
    }
    
    print(loopDisplayString(0, -1, Date()))
    
    for j in 0...(rCount - 1) {
        let tIJ = Date()
        for (_, stMols) in mDynDict[j]! {
            if mDynDict[j] != nil {
                mDynDict[j] = nil
            }
            for stMol in stMols {
                let rList = rAtoms.filter { !stMol.containsById($0) }
                for rAtom in rList {
                    let newMList = rcsConstructor(atom: rAtom, stMol: stMol, tolRange: tolRange, tolRatio: tolRatio)
                    
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
                    printStringInLine(loopDisplayString(j + 1, j, tIJ) + "Calculating..")
                    #endif
                }
            }
        }
        
        for atoms in globalCache.stMolMatched.1 {
            let saList = mDynDict[j + 1]![atoms]
            guard saList != nil && saList!.isEmpty == false else {
                continue
            }
            let combinedStMol: StrcMolecule = saList!.reduce(StrcMolecule(atoms), { $0.combined($1) ?? $0 })
            mDynDict[j + 1]![atoms] = [combinedStMol]

            #if DEBUG
            #else
            printStringInLine(loopDisplayString(j + 1, j, tIJ) + "Deduplicating..")
            #endif
        }
        
        print(toPrintWithSpace(loopDisplayString(j + 1, j, tIJ), 79))
        
        globalCache.stMolMatched = ([], [])
    }
    
    let result = mDynDict[rCount]!.flatMap({ $0.value })
    
    return result
}

extension Array where Element == Atom {
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

extension Collection where Iterator.Element == Atom {
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
        var cmVec = Vector3D()
        if self.count > 0 {
            var totalMass: Double = 0.0
            for atom in self {
                guard let rvec: Vector3D = atom.rvec else {
                    continue
                }
                guard let e = atom.element, let mass: Double = ChemConst.atomicMasses[e] else {
                    continue
                }
                totalMass = totalMass + mass
                cmVec = cmVec + mass * rvec
            }
            cmVec = cmVec / totalMass
        }
        return cmVec
    }
}

/**
 (D3APD) The distance between a degree-3 atom and the co-plane of its three adjacent atom.
 */
func degreeThreeAtomPlanarDistance(center: Atom, attached: [Atom]) -> Double? {
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

/**
 The bond angle of the two bonds of an atom. Takes the two attached atoms as parameter. *(Beta)*
 */
func bondAngle(center: Atom, attached: [Atom]) -> Measurement<UnitAngle>? {
    guard let theta = bondAngleInDeg(center: center, attached: attached) else {
        return nil
    }
    return Measurement<UnitAngle>(value: theta, unit: UnitAngle.degrees)
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached bonds as parameter. *(Beta)*
 */
func bondAngle(center: Atom, bonds: [ChemBond]) -> Measurement<UnitAngle>? {
    guard let theta = bondAngleInDeg(center: center, bonds: bonds) else {
        return nil
    }
    return Measurement<UnitAngle>(value: theta, unit: UnitAngle.degrees)
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached atoms as parameter. Returns the angle in degree. Has an option to turn on/off of the memoized dynamic programming (off by default).
 */
func bondAngleInDeg(center: Atom, attached: [Atom], dynProgammed: Bool = false) -> Double? {
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
func bondAngleInDegOriginal(center: Atom, attached: [Atom]) -> Double? {
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
func bondAngleInDeg(center: Atom, bonds: [ChemBond]) -> Double? {
    let attachedMap = bonds.map({ $0.atoms.subtracting([center])})
    let attachedAtoms = attachedMap.reduce(Set<Atom>(), {$0.union($1)})
    return bondAngleInDeg(center: center, attached: Array(attachedAtoms))
}


/**
 The bond angle of any number of bonds of an atom. Returns tuple of angle and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
func bondAngles(center: Atom, attached: [Atom]) -> [(Measurement<UnitAngle>?, Set<Atom>)] {
    let attachedAtomsList = combinationsDynProgrammed(attached, 2)
    return attachedAtomsList.map { (bondAngle(center: center, attached: Array($0)), $0) }
}

/**
 The bond angle of any number of bonds of an atom. Returns tuple of angle and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
func bondAngles(center: Atom, bonds: [ChemBond]) -> [(Measurement<UnitAngle>?, Set<ChemBond>)] {
    let attachedAtomsList = combinationsDynProgrammed(bonds, 2)
    return attachedAtomsList.map { (bondAngle(center: center, bonds: Array($0)), $0) }
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached atoms as parameter. Return the value of the angle given provided unit.
 */
func bondAngle(center: Atom, attached: [Atom], unit: UnitAngle) -> Double? {
    return bondAngle(center: center, attached: attached)?.converted(to: unit).value
}

/**
 The bond angle of the two bonds of an atom. Takes the two attached bonds as parameter. Return the value of the angle given provided unit.
 */
func bondAngle(center: Atom, bonds: [ChemBond], unit: UnitAngle) -> Double? {
    return bondAngle(center: center, bonds: bonds)?.converted(to: unit).value
}

/**
 The bond angle of any number of bonds of an atom. Returns tuple of the value of the angle given provided unit and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
func bondAngles(center: Atom, attached: [Atom], unit: UnitAngle) -> [(Double?, Set<Atom>)] {
    let attachedAtomsList = combinationsDynProgrammed(attached, 2)
    return attachedAtomsList.map { (bondAngle(center: center, attached: Array($0), unit: unit), $0) }
}

/**
 The bond angle of any number of bonds of an atom. Returns tuple of the value of the angle given provided unit and the set of the two bonds of the bond angle.
 */
func bondAngles(center: Atom, bonds: [ChemBond], unit: UnitAngle) -> [(Double?, Set<ChemBond>)] {
    let attachedAtomsList = combinationsDynProgrammed(bonds, 2)
    return attachedAtomsList.map { (bondAngle(center: center, bonds: Array($0), unit: unit), $0) }
}
/**
 The bond angle of any number of bonds of an atom. Returns tuple of the value of the angle in degrees and the set of the adjacent atoms involved in the two bonds of the bond angle.
 */
func bondAnglesInDeg(center: Atom, attached: [Atom]) -> [(Double?, Set<Atom>)] {
    let attachedAtomsList = combinationsDynProgrammed(attached, 2)
    return attachedAtomsList.map { (bondAngleInDeg(center: center, attached: Array($0)), $0) }
}

/**
 The bond angle of any number of bonds of an atom. Returns tuple of the value of the angle in degrees and the set of the two bonds of the bond angle.
 */
func bondAnglesInDeg(center: Atom, bonds: [ChemBond]) -> [(Double?, Set<ChemBond>)] {
    let attachedAtomsList = combinationsDynProgrammed(bonds, 2)
    return attachedAtomsList.map { (bondAngleInDeg(center: center, bonds: Array($0)), $0) }
}
