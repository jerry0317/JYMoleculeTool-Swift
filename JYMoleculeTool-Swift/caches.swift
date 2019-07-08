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

var globalCache = GlobalCache()

/**
 Provides a structure for cache that is easily to access globally.
 */
struct GlobalCache {
    var indexCombinations: [CombTuple: Set<Set<Int>>] = [:]
    
    var rcsConstructorCache: Set<rcsConstructorTuple> = []
    
    var possibleBondTypes: [Set<ChemElement>: [ChemBondType]] = [:]
    
    var stMolMatched: (Set<Set<Atom>>, Set<Set<Atom>>) = ([], [])
    
    var atomPossibles: [Atom: [Atom]] = [Atom: [Atom]]()
    
    var bdCodes: [ChemBondType: String] = [ChemBondType: String]()
    
    var bondAngles: [Array<Atom>: Double] = [Array<Atom>: Double]()
}

struct CombTuple {
    var n: Int
    var k: Int
    
    init(_ n: Int, _ k: Int) {
        self.n = n
        self.k = k
    }
}

extension CombTuple: Hashable {
    static func == (lhs: CombTuple, rhs: CombTuple) -> Bool {
        return lhs.n == rhs.n && lhs.k == rhs.k
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(n)
        hasher.combine(k)
    }
}

struct rcsConstructorTuple {
    var atom: Atom
    var stMol: StrcMolecule
}

extension rcsConstructorTuple: Hashable {
    static func == (lhs: rcsConstructorTuple, rhs: rcsConstructorTuple) -> Bool {
        return lhs.atom == rhs.atom && lhs.stMol == rhs.stMol
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(atom)
        hasher.combine(stMol)
    }
}
