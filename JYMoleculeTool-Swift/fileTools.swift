//
//  fileTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 6/21/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

protocol File {
    
}

/**
 Structure of `.xyz` file.
 */
struct XYZFile: File {
    /**
     The number of atoms. The first line.
     */
    var count: Int?
    
    /**
     The second line. Usually energy.
     */
    var note: String?
    
    /**
     The information of atoms contained in the molecule.
     */
    var atoms: [Atom]?
    
    init(){
        
    }
    
    init(fromString str: String) {
        (count, note, atoms) = importFromString(str)
    }
    
    init(fromURL url: URL, encoding: String.Encoding = .utf8) throws {
        let contents = try String(contentsOf: url, encoding: encoding)
        self.init(fromString: contents)
    }
    
    init(fromPath path: String, encoding: String.Encoding = .utf8) throws {
        let urlPath = URL(fileURLWithPath: path)
        try self.init(fromURL: urlPath)
    }
    
    private func importFromString(_ str: String) -> (Int?, String?, [Atom]?) {
        let lines = str.split {$0.isNewline}
        var countFromFile: Int? = nil
        var noteFromFile: String? = nil
        var atomsFromFile: Array<Atom>? = nil
        
        for (i, line) in lines.enumerated() {
            switch i {
            case 0:
                guard let c: Int = Int(line) else {
                    countFromFile = nil
                    break
                }
                countFromFile = c
            case 1:
                noteFromFile = String(line)
            default:
                if atomsFromFile == nil {
                    atomsFromFile = []
                }
                let elements = line.split(separator: " ")
                guard elements.count == 4 else {
                    break
                }
                let atomName = String(elements[0])
                var rvec = Vector3D()
                for j in 1...3 {
                    guard let r: Double = Double(elements[j]) else {
                        break
                    }
                rvec.dictVec[j - 1] = r
                }
                let atom = Atom(atomName, rvec)
                atomsFromFile!.append(atom)
            }
        }
        return (countFromFile, noteFromFile, atomsFromFile)
    }
}

