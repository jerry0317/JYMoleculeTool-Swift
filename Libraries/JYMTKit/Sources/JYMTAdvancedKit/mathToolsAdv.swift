//
//  mathToolsAdv.swift
//  
//
//  Created by Jerry Yan on 7/18/19.
//
//  This is the advanced part of the mathTools in JYMTBasicKit.
//  Advanced computationss such as eigenvalues and eigenvectors
//  will be implemented with the integration of Python's NumPy
//  library.
//
//
//  UNDER DEVELOPMENT...
//
//

import Foundation
import JYMTBasicKit
import PythonKit

public extension Matrix {
    var npForm: PythonObject {
        let np = Python.import("numpy")
        return np.array(content)
    }
    
    func eigenSystem() -> ([Double]?, [[Double]]?)? {
        guard isSquareMatrix else {
            return nil
        }
        let LA = Python.import("numpy.linalg")
        let result = LA.eig(npForm)
        return ([Double](result[0]), [[Double]](result[1]))
    }
}
