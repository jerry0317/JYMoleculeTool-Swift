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

import Foundation
import JYMTBasicKit
import PythonKit

public extension Matrix {
    /**
     The numpy 2-D array of the information contained in the matrix.
     */
    var npForm: PythonObject {
        let np = Python.import("numpy")
        return np.array(content)
    }
    
    /**
     Find the eigensystem of the matrix.
     
     - Returns:
        - an optional tuple containing a 1-D optional array presenting the eigenvalues and a 2-D optional array presenting the corresponding eigenvectors.
        - `nil`: if the matrix is not a square matrix.
        - `(nil, nil)`: if the function failed to parse the result from Python's NumPy library *(This can happen when the eigenvalues/eigenvectors containing complex value)*.
     */
    func eigenSystem() -> ([Double]?, [[Double]]?)? {
        guard isSquareMatrix else {
            return nil
        }
        let LA = Python.import("numpy.linalg")
        let result = LA.eig(npForm)
        return ([Double](result[0]), [[Double]](result[1]))
    }
}
