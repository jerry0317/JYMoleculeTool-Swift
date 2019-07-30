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
public protocol File {
    /**
     The content (raw in string) of the file.
     */
    var content: String { get set }
}

public extension File {
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
 A typealias of file exporting error.
 */
public typealias FileExportError = FileError.Exporting

/**
 Errors that could appear in file operations.
 */
public enum FileError {
    /**
     Errors that could appear in the exporting process of files.
     */
    public enum Exporting: Error {
        /**
         The file is not valid to export.
         */
        case fileIsNotValid
    }
}

/**
 Structure of `.xyz` file.
 */
public struct XYZFile: File {
    /**
     The number of atoms. The first line.
     */
    public var count: Int?
    
    /**
     The second line. Usually energy.
     */
    public var note: String?
    
    /**
     The information of atoms contained in the molecule.
     */
    public var atoms: [Atom]?
    
    public init(){
        
    }
    
    public init(fromString str: String) {
        (count, note, atoms) = importFromString(str)
    }
    
    public init(fromURL url: URL, encoding: String.Encoding = .utf8) throws {
        try open(fromURL: url, encoding: encoding)
    }
    
    public init(fromPath path: String, encoding: String.Encoding = .utf8) throws {
        let urlPath = URL(fileURLWithPath: path)
        try open(fromURL: urlPath, encoding: encoding)
    }
    
    public init(fromAtoms atoms: [Atom]) {
        self.importFromAtoms(atoms)
    }
    
    /**
     The `File` protocol-compliant content.
     */
    public var content: String {
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
    public var xyzString: String? {
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
    public mutating func importFromAtoms(_ atomList: [Atom], note comment: String = "") {
        count = atomList.count
        note = comment
        atoms = atomList
    }
    
    /**
     Export the xyz file to URL.
     */
    public func export(toFile path: URL) throws {
        guard xyzString != nil else {
            throw FileExportError.fileIsNotValid
        }
        try save(xyzString!, asURL: path)
    }
    
    /**
     Safely export the xyz file to URL. Print the error when the error raises.
     */
    public func safelyExport(toFile path: URL) {
        do {
            try export(toFile: path)
        } catch let error {
            print("An error occured when saving xyz file: \(error).")
        }
    }
}

extension XYZFile: CustomStringConvertible {
    public var description: String {
        guard let ats = atoms else {
            return "(Invalid Set)"
        }
        return ats.map({"\($0.name)     \($0.rvec!)"}).joined(separator: "\n")
    }
}

/**
 The structure of text file. Usually indicates `.txt` files.
 */
public struct TextFile: File {
    /**
     The `File` protocol-compliant content.
     */
    public var content: String = ""
    
    public init() {
        
    }
    
    public init(fromURL url: URL, encoding: String.Encoding = .utf8) throws {
        try open(fromURL: url, encoding: encoding)
    }
    
    /**
     Add anything to the file. Optional terminator with default for a new line.
     
     - The function is designed in this way to make it similar to the `Swift.print` function.
     - Parameters:
        - item: An `Any` item that will be converted to sting by `String(describing: item)`. The default is empty string ("").
        - terminator: The terminator to end the content. The default value is a new line ("\n")
        - print: If `true`, then the function will print the content to the console. The default value is `true`.
     */
    public mutating func add(_ item: Any = "", terminator: String = "\n", print: Bool = true) {
        let str = String(describing: item) + terminator
        if print {
            Swift.print(str, terminator: "")
        }
        content.append(str)
    }
    
    /**
     Print the content of the text file with optional terminator.
     */
    public func print(terminator: String = "\n") {
        Swift.print(content, terminator: terminator)
    }
}

public struct SABCFile: File {
    /**
     The `File` protocol-compliant content.
     */
    public var content: String {
        get {
            exportToString(original: original, comment: comment, substituted: substituted) ?? ""
        }
        set {
            self = .init(fromString: newValue)
        }
    }
    
    /**
     The rotational constants of the original molecules.
     */
    public var original: ABCTuple?
    
    /**
     The comment line of `.sabc` file.
     */
    public var comment: String?
    
    /**
     The rotational constants of each single isotopic substitution (SIS).
     */
    public var substituted: [ABCTuple]?
    
    /**
     Returns true if both `original` and `substituted` are not `nil`.
     */
    public var isValid: Bool {
        original != nil && substituted != nil
    }
    
    public init() {
        
    }
    
    public init(fromString str: String) {
        (original, comment, substituted) = importFromString(str)
    }
    
    public init(fromURL url: URL, encoding: String.Encoding = .utf8) throws {
        try open(fromURL: url, encoding: encoding)
    }
    
    public init(fromPath path: String, encoding: String.Encoding = .utf8) throws {
        let urlPath = URL(fileURLWithPath: path)
        try open(fromURL: urlPath, encoding: encoding)
    }
    
    /**
     Export the current set to an optional string.
     */
    private func exportToString(original: ABCTuple?, comment: String?, substituted: [ABCTuple]?) -> String? {
        guard let ori = original, let subs = substituted else {
            return nil
        }
        var str: String = ""
        str = str + "\(ori.A)    \(ori.B)    \(ori.C)    \(ori.totalAtomicMass)\n"
        str = str + (comment ?? "")
        for s in subs {
            guard s.isSIS else {
                continue
            }
            str = str + "\(s.A)    \(s.B)    \(s.C)    \(s.substitutedAtomicMasses[0])   \(s.substitutedIsotopes[0].0.rawValue)\n"
        }
        return str
    }
    
    /**
     Import the set from an optional string.
     */
    private func importFromString(_ str: String) -> (ABCTuple?, String?, [ABCTuple]?) {
        let lines = str.split(omittingEmptySubsequences: false, whereSeparator: {$0.isNewline})
        var originalFromFile: ABCTuple? = nil
        var commentFromFile: String? = nil
        var substitutedFromFile: [ABCTuple]? = nil
        
        for (i, line) in lines.enumerated() {
            switch i {
            case 1:
                commentFromFile = String(line)
            default:
                guard !line.isEmpty else {
                    break
                }
                let elements = line.split(separator: " ")
                guard elements.count == (i == 0 ? 4 : 5) else {
                    break
                }
                var abcTuple = ABCTuple()
                for j in 0...2 {
                    guard let r: Double = Double(elements[j]) else {
                        break
                    }
                    abcTuple[j] = r * 1e6
                }
                guard let m: Double = Double(elements[3]) else {
                    break
                }
                if i == 0 {
                    abcTuple.totalAtomicMass = m
                    originalFromFile = abcTuple
                } else {
                    let substitutedMassNumber = Int(m)
                    guard let element: ChemElement = ChemElement(rawValue: String(elements[4])) else {
                        break
                    }
                    
                    abcTuple.substitutedIsotopes.append((element, substitutedMassNumber))
                    abcTuple.totalAtomicMass = originalFromFile!.totalAtomicMass + abcTuple.deltaAtomicMasses[0]
                    if substitutedFromFile == nil {
                        substitutedFromFile = []
                    }
                    substitutedFromFile!.append(abcTuple)
                }
            }
        }
        return (originalFromFile, commentFromFile, substitutedFromFile)
    }
    
    /**
     Calculate the information of current information in the set to an array of atoms.
     */
    public func exportToAtoms() -> [Atom] {
        guard let oABC = original, let sABCs = substituted, oABC.isParent else {
            return []
        }
        return fromSISToAtoms(original: oABC, substituted: sABCs)
    }
    
    /**
     Export the information of the current set to an XYZ set.
     */
    public func exportToXYZ() -> XYZFile {
        return XYZFile(fromAtoms: exportToAtoms())
    }
}

/**
 The `.mol` file describes both atoms and bonds in the molecule.
 
 - TODO: Add importing feature (not rush)
 */
public struct MOLFile: File {
    /**
     The `File` protocol-compliant content.
     */
    public var content: String {
        get {
            molString ?? ""
        }
        set {
            // Not available yet
        }
    }
    
    public var title: String = ""
    
    public var timestamp: String?
    
    public var comment: String = ""
    
    public var atoms: [Atom]?
    
    public var bonds: [ChemBond]?
    
    public init() {
        
    }
    
    public init(title: String, comment: String = "", atoms: [Atom], bonds: [ChemBond], setTS: Bool = true){
        self.title = title
        self.atoms = atoms
        self.bonds = bonds
        self.comment = comment
        if setTS {
            setTimeStamp()
        }
    }
    
    public init(title: String, comment: String = "", atoms: Set<Atom>, bonds: Set<ChemBond>, setTS: Bool = true){
        self.init(title: title, comment: comment, atoms: Array(atoms), bonds: Array(bonds), setTS: setTS)
    }
    
    public var isValid: Bool {
        timestamp != nil && atoms != nil && bonds != nil
    }
    
    private var atomIndices: [Atom: Int]? {
        guard let atomList = atoms else {
            return nil
        }
        var dict = [Atom: Int]()
        for (i, atom) in atomList.enumerated() {
            dict[atom] = i
        }
        return dict
    }
    
    private var atomsFormalized: [String]? {
        guard let atomList = atoms else {
            return nil
        }
        var formalizedList = [String]()
        for atom in atomList {
            guard let rvec = atom.rvec, let element = atom.element else {
                continue
            }
            let rvecStrings = rvec.dictVec.map({ (comp) -> String in
                let preStr = String(format: "%.4f", comp)
                return preStr.withSpace(10, trailing: false)
            })
            let rvecString = rvecStrings.joined(separator: "")
            formalizedList.append("\(rvecString) \(element.rawValue.withSpace(2, trailing: false))   0  0  0  0  0  0  0  0  0  0  0  0")
        }
        return formalizedList
    }
    
    private var bondsFormalized: [String]? {
        guard let atomDict = atomIndices, let bondList = bonds else {
            return nil
        }
        var formalizedList = [String]()
        for bond in bondList {
            let atomArray = Array(bond.atoms)
            let (atom1, atom2) = (atomArray[0], atomArray[1])
            guard let index1 = atomDict[atom1], let index2 = atomDict[atom2] else {
                continue
            }
            let codesList: [Int] = [index1 + 1, index2 + 1, bond.type.order]
            let codeString = codesList.map({ String(describing: $0).withSpace(3, trailing: false) }).joined(separator: "")
            formalizedList.append("\(codeString)  0  0  0  0")
        }
        return formalizedList
    }
    
    public var molString: String? {
        guard let atomFList = atomsFormalized, let bondFList = bondsFormalized else {
            return nil
        }
        return exportToString(title: title, timestamp: self.timestamp ?? timeStampNow(), comment: comment, atomsFormalized: atomFList, bondsFormalized: bondFList)
    }
    
    private mutating func setTimeStamp() {
        timestamp = timeStampNow()
    }
    
    private func timeStampNow() -> String {
        let timeNow = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyyHHmm"
        return "JYMoleculeTool" + dateFormatter.string(from: timeNow) + "3D"
    }
    
    private func exportToString(title: String, timestamp: String, comment: String, atomsFormalized atomFList: [String], bondsFormalized bondFList: [String]) -> String {
        var str = ""
        str += "\(title)\n"
        str += " \(timestamp)\n"
        str += "\(comment)\n"
        str += " \(String(atomFList.count).withSpace(2, trailing: false)) \(String(bondFList.count).withSpace(2, trailing: false))  0  0  0  0  0  0  0  0999 V2000\n"
        str += atomFList.joined(separator: "\n")
        str += "\n"
        str += bondFList.joined(separator: "\n")
        str += "\n"
        str += "M  END"
        return str
    }
    
    /**
     Export the mol file to URL.
     */
    public func export(toFile path: URL) throws {
        guard molString != nil else {
            throw FileExportError.fileIsNotValid
        }
        try save(molString!, asURL: path)
    }
    
    /**
     Safely export the mol file to URL. Print the error when the error raises.
     */
    public func safelyExport(toFile path: URL) {
        do {
            try export(toFile: path)
        } catch let error {
            print("An error occured when saving mol file: \(error).")
        }
    }
    
}

public extension URL {
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
