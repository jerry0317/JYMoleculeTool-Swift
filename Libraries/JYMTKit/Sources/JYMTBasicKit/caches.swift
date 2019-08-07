//
//  caches.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 7/4/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//
//  This is a page mainly built for storing cache information to avoid repetitive calculation and optimize runtime.
//  (Currently experimental)
//

import Foundation

public var globalCache = GlobalCache()

/**
 Provides a structure for cache that is easily to access globally.
 */
public struct GlobalCache {
    /**
     The combinations of indices based on `C(n,k)`.
     */
    public var indexCombinations: [CombTuple: Set<Set<Int>>] = [:]
    
    /**
     A cache containing the tuples of `atom` and `stMol`.
     */
    public var rcsConstructorCache: Set<RcsConstructorTuple> = []
    
    /**
     Cached possible bond types keyed by the **Array** of `ChemElement`.
     */
    public var possibleBondTypes: [Array<ChemElement>: [ChemBondType]] = [:]
    
    /**
     Cached minimum bond lengths keyed by the **Array** of `ChemElement`. The minimum bond lengths should be found by the minimum bond length in the `constants.swift`.
     */
    public var minimumBondLength: [Array<ChemElement>: Double] = [:]
    
    /**
     Record how many times the atoms has been matched by structure molecules.
     
     - If the set of atoms is in `stMolMatched.0`, then it has been matched only once (unique).
     - If the set of atoms is in `stMolMatched.1`, then it has been matched twice or more (duplicated).
     */
    public var stMolMatched: (Set<Set<Atom>>, Set<Set<Atom>>) = ([], [])
    
    /**
     The cached possible atoms after re-signing.
     */
    public var atomPossibles: [Atom: [Atom]] = [Atom: [Atom]]()
    
    /**
     The cached `bdCodes` of bond types.
     */
    public var bdCodes: [ChemBondType: BondCode] = [:]
    
    /**
     The cached bond angles keyed by a tuple containing the center atom, the first adjacent atom, and the second adjacent atom.
     */
    public var bondAngles: [BondAngleTuple: Double] = [:]
    
    /**
     The cached neighbors of an atom in a bond.
     
     - It's keyed by a set of atom and the origin atom. If there's a neighbor, it will record  `(true, neighbor)`. If there're no neighbors, it will record `(false, self)`.
     */
    public var atomNeighbors: [AtomNeighborTuple: (Bool, Atom)] = [:]
}

public struct CombTuple {
    public var n: Int
    public var k: Int
    
    public init(_ n: Int, _ k: Int) {
        self.n = n
        self.k = k
    }
}

extension CombTuple: Hashable {
    public static func == (lhs: CombTuple, rhs: CombTuple) -> Bool {
        return lhs.n == rhs.n && lhs.k == rhs.k
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(n)
        hasher.combine(k)
    }
}

public struct RcsConstructorTuple {
    public var atom: Atom
    public var stMol: StrcMolecule
}

extension RcsConstructorTuple: Hashable {
    public static func == (lhs: RcsConstructorTuple, rhs: RcsConstructorTuple) -> Bool {
        return lhs.atom == rhs.atom && lhs.stMol == rhs.stMol
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(atom)
        hasher.combine(stMol)
    }
}

public struct AtomNeighborTuple {
    public var atoms: Set<Atom>
    public var atom: Atom
    
    public init(_ atoms: Set<Atom>, _ atom: Atom) {
        self.atoms = atoms
        self.atom = atom
    }
}

extension AtomNeighborTuple: Hashable {
    public static func == (lhs: AtomNeighborTuple, rhs: AtomNeighborTuple) -> Bool {
        return lhs.atom == rhs.atom && lhs.atoms == rhs.atoms
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(atom)
        hasher.combine(atoms)
    }
}

public struct BondAngleTuple {
    public var center: Atom
    public var atom1: Atom
    public var atom2: Atom
    
    public init(_ center: Atom, _ atom1: Atom, _ atom2: Atom) {
        self.center = center
        self.atom1 = atom1
        self.atom2 = atom2
    }
    
    public init?(_ center: Atom, attached: [Atom]) {
        guard attached.count == 2 else {
            return nil
        }
        
        self.init(center, attached[0], attached[1])
    }
}

extension BondAngleTuple: Hashable {
    public static func == (lhs: BondAngleTuple, rhs: BondAngleTuple) -> Bool {
        return lhs.center == rhs.center && lhs.atom1 == rhs.atom1 && lhs.atom2 == rhs.atom2
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(center)
        hasher.combine(atom1)
        hasher.combine(atom2)
    }
}

