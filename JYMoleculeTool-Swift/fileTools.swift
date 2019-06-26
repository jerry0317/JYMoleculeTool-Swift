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
    
    init(fromAtoms atoms: [Atom]) {
        self.importFromAtoms(atoms)
    }
    
    var xyzString: String? {
        guard count != nil && note != nil && atoms != nil else {
            return nil
        }
        
        var str: String
        str = String(count!) + "\n" + note! + "\n"
        for atom in atoms! {
            guard atom.rvec != nil else {
                continue
            }
            let rvec = atom.rvec!.dictVec
            str = str + "\(atom.name)   \(rvec[0])  \(rvec[1])  \(rvec[2])\n"
        }
        return str
    }
    
    private func importFromString(_ str: String) -> (Int?, String?, [Atom]?) {
        let lines = str.split(omittingEmptySubsequences: false, whereSeparator: {$0.isNewline})
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
                guard !line.isEmpty else {
                    break
                }
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
    
    mutating func importFromAtoms(_ atomList: [Atom], note comment: String = "") {
        count = atomList.count
        note = comment
        atoms = atomList
    }
    
    enum xyzExportError: Error {
        case xyzStringIsNil
    }
    
    func export(toFile path: URL) throws {
        guard xyzString != nil else {
            throw xyzExportError.xyzStringIsNil
        }
        let data = Data(xyzString!.utf8)
        do {
            try data.write(to: path)
        } catch let error {
            throw error
        }
    }
}

extension URL {
    var lastPathComponentName: String {
        let lastPath = self.lastPathComponent
        var components = lastPath.components(separatedBy: ".")
        if components.count > 1 {
            components.removeLast()
            return components.joined(separator: ".")
        } else {
            return lastPath
        }
    }
}
