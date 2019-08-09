//
//  miscTools.swift
//  JYMTBasicKit
//
//  Created by Jerry Yan on 8/8/19.
//

import Foundation

/**
 The program mode used by Structure Finder or related processes.
 */
public enum SFProgramMode {
    /**
     The test mode is to test whether a known molecule will pass all the filters or not. In the test mode, the program will not re-sign the coordinates.
     */
    case test
    
    /**
     The simple mode is to run with all default parameters.
     */
    case simple
    
    /**
     The ordinary mode.
     */
    case ordinary
}

/**
 A packed input module for importing `.xyz` file.
 
 - Returns: a tuple `(XYZFile, String)` where the first element is the imported XYZ file and the second element is the last component name of the `.xyz` file.
 */
public func xyzFileInput() -> (XYZFile, String) {
    var xyzSet = XYZFile()
    var fileName = ""
    fileInput(name: "XYZ file", tryAction: { (filePath) in
        xyzSet = try XYZFile(fromPath: filePath)
        fileName = URL(fileURLWithPath: filePath).lastPathComponentName
        guard xyzSet.atoms != nil && !xyzSet.atoms!.isEmpty else {
            print("No Atoms in xyz file. Can not proceed.")
            return false
        }
        return true
    })
    return (xyzSet, fileName)
}

/**
 A packed input module for importing `sabc`file.
 
 - Returns: a tuple `(SABCFile, String)` where the first element is the imported SABC file and the second element is the last component name of the `sabc` file.
 */
public func sabcFileInput() -> (SABCFile, String) {
    var sabcSet = SABCFile()
    var fileName = ""
    fileInput(name: "SABC file") { (filePath) -> Bool in
        sabcSet = try SABCFile(fromPath: filePath)
        if !sabcSet.isValid {
            print("Not a valid SABC file.")
            return false
        }
        if sabcSet.substituted!.isEmpty {
            print("No SIS information.")
            return false
        }
        fileName = URL(fileURLWithPath: filePath).lastPathComponentName
        return true
    }
    return (sabcSet, fileName)
}

/**
 A packed input module for optional selecting exporting path.
 
 - Returns: a tuple `(Bool, URL)` where the first element whether the user decided to save results or not, and the second element is the `URL` of the user-selected exporting path.
    - The second element is meaningless if the first element returns `false`.
 */
public func exportingPathInput(_ name: String = "") -> (Bool, URL) {
    var saveResults = true
    var writePath = URL(fileURLWithPath: "")
    fileInput(message: "\(name) exporting Path (leave empty if not to save)", successMessage: false) { (writePathInput) in
        if writePathInput.isEmpty {
            saveResults = false
            print("The results will not be saved.")
            return true
        } else {
            let writePathUrl = URL(fileURLWithPath: writePathInput)
            guard writePathUrl.hasDirectoryPath else {
                print("Not a valid directory. Please try again.")
                return false
            }
            writePath = writePathUrl
            print("The result will be saved in \(writePath.relativeString).")
            return true
        }
    }
    return (saveResults, writePath)
}

/**
 Create a new directory with optional sub-directories.
 
 - Returns: a tuple `(URL, [URL])` where the first element is the path of the directory (if success) and the second element is the paths of the sub-directories that has been created (if success).
 */
@discardableResult
public func createNewDirectory(_ name: String, subDirectories: [String] = [], at basePath: URL, withIntermediateDirectories: Bool = false) -> (URL, [URL]) {
    var subDirPaths = [URL]()
    do {
        let newDirectoryPath = basePath.appendingPathComponent(name, isDirectory: true)
        try FileManager.default.createDirectory(at: newDirectoryPath, withIntermediateDirectories: withIntermediateDirectories)
        for subName in subDirectories {
            let subPath = newDirectoryPath.appendingPathComponent(subName, isDirectory: true)
            try FileManager.default.createDirectory(at: subPath, withIntermediateDirectories: withIntermediateDirectories)
            subDirPaths.append(subPath)
        }
        return (newDirectoryPath, subDirPaths)
    } catch let error {
        print("An error occured when creating a new directory: \(error).")
    }
    subDirPaths += [URL](repeating: basePath, count: subDirectories.count - subDirPaths.count)
    return (basePath, subDirPaths)
}

/**
 Create a string combination function used with ABC Calculator and MIS Calculator.
 */
public func createStringIdFunction(_ idDict: [Int: Int]) -> (([Atom]) -> ([String], [Int], [Int])) {
    let stringIdsOfAtoms: (([Atom]) -> ([String], [Int], [Int])) = {
        var result = [String]()
        var idResult = [Int]()
        for atom in $0 {
            guard let identifier = atom.identifier, let id = idDict[identifier] else {
                continue
            }
            result.append(atom.name + String(id + 1))
            idResult.append(id)
        }
        let order = (0..<result.count).sorted(by: {idResult[$0] < idResult[$1]})
        return (result, idResult, order)
    }
    return stringIdsOfAtoms
}

/**
 A depth attribute for isotopic substitutions.
 */
public func depthForISStr(_ depth: Int) -> String {
    var depthStr = ""
    switch depth {
    case 1:
        depthStr = "Single"
    case 2:
        depthStr = "Double"
    case 3:
        depthStr = "Triple"
    default:
        depthStr = "\(depth)-atom"
    }
    return depthStr
}
