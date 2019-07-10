//
//  fileTools.swift
//  JYMoleculeTool-Swift
//
//  Created by Jerry Yan on 6/21/19.
//  Copyright © 2019 Jerry Yan. All rights reserved.
//

import Foundation

/**
 The protocol for a file.
 
 - Provide ability to open the file from URL and save the file from URL.
 */
protocol File {
    /**
     The content (raw in string) of the file.
     */
    var content: String { get set }
}

extension File {
    /**
     Open the file from a given URL with certain encoding.
     */
    mutating func open(fromURL url: URL, encoding: String.Encoding = .utf8) throws {
        content = try String(contentsOf: url, encoding: encoding)
    }
    
    /**
     Save the file (or something else) to a certain URL with certain encoding.
     */
    func save(_ content: String? = nil, asURL url: URL, encoding: String.Encoding = .utf8) throws {
        let str: String = content ?? self.content
        var data = str.data(using: encoding)
        if data == nil {
            data = str.data(using: .utf8)
            print("Force encoding to utf8.")
        }
        do {
            try data!.write(to: url)
        } catch let error {
            throw error
        }
    }
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
        try open(fromURL: url, encoding: encoding)
    }
    
    init(fromPath path: String, encoding: String.Encoding = .utf8) throws {
        let urlPath = URL(fileURLWithPath: path)
        try open(fromURL: urlPath, encoding: encoding)
    }
    
    init(fromAtoms atoms: [Atom]) {
        self.importFromAtoms(atoms)
    }
    
    /**
     The `File` protocol-compliant content.
     */
    var content: String {
        get {
            return xyzString ?? ""
        }
        set(newString) {
            self = .init(fromString: newString)
        }
    }
    
    /**
     The xyz string.
     */
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
    
    /**
     Import the xyz file from a string.
     */
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
                atom.setIdentifier()
                atomsFromFile!.append(atom)
            }
        }
        return (countFromFile, noteFromFile, atomsFromFile)
    }
    
    /**
     Import the xyz file from atoms.
     */
    mutating func importFromAtoms(_ atomList: [Atom], note comment: String = "") {
        count = atomList.count
        note = comment
        atoms = atomList
    }
    
    /**
     Errors describing the xyz exporting process.
     */
    enum xyzExportError: Error {
        case xyzStringIsNil
    }
    
    /**
     Export the xyz file to URL.
     */
    func export(toFile path: URL) throws {
        guard xyzString != nil else {
            throw xyzExportError.xyzStringIsNil
        }
        try save(xyzString!, asURL: path)
    }
}

/**
 The structure of text file. Usually indicates `.txt` files.
 */
struct TextFile: File {
    /**
     The `File` protocol-compliant content.
     */
    var content: String = ""
    
    init() {
        
    }
    
    init(fromURL url: URL, encoding: String.Encoding = .utf8) throws {
        try open(fromURL: url, encoding: encoding)
    }
    
    /**
     Add anything to the file. Optional terminator with default for a new line.
     
     - The function is designed in this way to make it similar to the `Swift.print` function.
     */
    mutating func add(_ item: Any = "", terminator: String = "\n") {
        let str = String(describing: item)
        content.append(str + terminator)
    }
    
    /**
     Print the content of the text file with optional terminator.
     */
    func print(terminator: String = "\n") {
        Swift.print(content, terminator: terminator)
    }
}

extension URL {
    /**
     The last path component name of the url.
     
     - For example, for `/folder/file.txt`, the function returns `file`.
     */
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
