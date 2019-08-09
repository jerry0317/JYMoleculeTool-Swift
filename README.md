# JYMoleculeTool-Swift

### Overview
The project provides tools for analyzing molecules based on physical and chemical equations.

The project currently includes the following tools:
- Structure Finder
- ABC Tool
- ABC Calculator
- MIS Calculator *(Under early development)*

The programs currently support molcules containing hydrogen\*, carbon, oxygen, nitrogen, fluorine, and chlorine atoms.

*\*Note: Hydrogen atoms will be neglected in Structure Finder and MIS Calculator.* Hydrogen atoms are of little significance in structure determination. Also, in isotopic substitutions, H/D substitutions are much more unpredictable than other substitutions because of the magnification of rovibrational effect on small masses.

### Requirements
#### Swift
The code is written on Swift 5.1, thus any compilation should be performed on the compiler of Swift 5.1 or newer versions. The executables should be working on environments that has Swift 5.1 installed.

|System Version|Swift Version|Status|
|---|---|---|
|macOS 10.14.5|Swift 5.1|Verified|
|macOS 10.15 beta|Swift 5.1|Verified|
|Ubuntu 18.04.2 LTS|Swift 5.1|Verified|
|Ubuntu 18.04 (WSL)|Swift 5.1|Verified|
|macOS 10.14.5|Swift 5.0.1|Unable to compile\*|

*\*For Swift 5.0.1, the program is not able to compile, but the exectuables are able to run on Swift 5.0.1.*

To learn how to install Swift, please [visit here](https://swift.org/download/#snapshots). In the "Snapshots" section, select **Swift 5.1 Development**. Windows 10 users may install Swift on [Windows Subsytem of Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl).

#### SPM Dependencies
The module `JYMTAdvancedKit` for advanced calculations utilizes [`PythonKit`](https://github.com/pvieito/PythonKit) as dependency, which is hosted on GitHub. Therefore, for direct running through `swift run` or compiling through `swift build`, an internet connection may be required to fetch the external SPM dependencies.

### Compile

To compile all the executables with swift package manager, use

```
swift build -c release; mv ./.build/release/JYMT-* ./; rm -rf ./*.product
```

and run any executable by

```
./JYMT-[Tool Name]
```

You'll be able to find how to compile and run for each specific tool in the sections below.

### Models and Results

Some molecule models and results produced from this set of tool can be founded on this [repository](https://github.com/jerry0317/JYMoleculeTool-Results). The results will be updated routinely to match the latest version of the tools. 

## Structure Finder
Structure Finder provides the ability to calculate the possible structures of a molecule from the known absolute values (or sign-undetermined values) of positions |x|, |y|, and |z| for each atom in the molecule. The latter data can be obtained via the single isotope substitution based on Kraitchman's equations.

*Note: the program ignores hydrogen atoms in the calculation, and the hydrogen atoms are not included in the output results.*

### Dependencies
The tool uses library `JYMTBasicKit`.

### Usage
- Download the executable from the [release](https://github.com/jerry0317/JYMoleculeTool-Swift/releases/latest).
- Alternatively, run the program directly by
```
swift run -c release JYMT-StructureFinder
```
- Or compile the executable by
```
swift build --product JYMT-StructureFinder -c release; mv ./.build/release/JYMT-StructureFinder JYMT-StructureFinder
```
and run the executable by
```
./JYMT-StructureFinder
```

*Note: Make sure the environment installed Swift 5.1. The Swift 5.0 compiler won't compile as there will be some errors.*

#### Test Mode

Test mode is available for use in version 0.1.3 or later. Enter the test mode by passing the command line argument `-t`. For example, you can run the exeuctable and enter the test mode by

```
./JYMT-StructureFinder -t
```

Use test mode to test whether a known molecule will pass all the filters (with given parameters listed [here](#options)) or not. In the test mode, the program will not re-sign the coordinates.

#### Simple Mode

Simple mode is available for use in version 0.1.4 or later. Enable the simple mode by passing the command line argument `-s`. In simple mode, all the parameters will be set to default values and you will not be promopted to enter them. You still need to identify the input xyz file path and optional exporting path.

You can use the simple mode and test mode at the same time by passing the commmand line arguments `-s -t` or `-t -s`.

### Input

The tool takes a `.xyz` file as input for the known absolute values (or sign-undetermined values) of positions |x|, |y|, and |z| for each atom in the molecule *with unit in angstrom*. The sign of each value can be incorrect, but their value (absolute value) must be matched (within allowed uncertainties) to the ultimate correct structure. The `.xyz` file looks like below.

```
4

C   -5.43  2.04  -0.14
O   -3.44  3.38  -0.19
C   -3.91  2.04  -0.11
C   -3.37  1.4  1.16
```

### Output
The tool will print the output to the console, and there is an option to save the results as `.xyz` files (which contains only coordinate information) and `.mol` files (which contains both coordinate information and bond information\*), and the log as `.txt` file.

You can visualize the `.xyz` files and `.mol` files with softwares like [Avogadro](https://avogadro.cc).

\**Note: ~~For `.mol` files, one (or more) bonds might be missing if some atoms in the molecule form a closed structure (for example, benzene ring). This problem will be fixed in future versions.~~ This problem appeared to be solved in version 0.1.2, or after git commit [66cea02](https://github.com/jerry0317/JYMoleculeTool-Swift/commit/66cea02), while the actual results are still to be verified.*

### Options
- XYZ file path **(Required)**
  - You will be prompted to enter the input xyz file path. You can either enter the relative/absolute file path or drag the file to the console.
- XYZ & MOL exporting path (Optional)
  - If you want to save the results, please enter/drag the folder where you want to save the results in.
  - If you don't want to save the results, just leave it empty.
- Bond length tolerance level in angstrom (Optional)
  - You'll be prompted to enter a desired value if you want to customize the tolerance level used in bond length filters and co-planarity filters. If the distance between two atoms lies in the bond length range extended by the tolerance level, the program will form a bond between these two atoms. The formula for the range is `(bondLengthRange.min - tolLevel, bondLengthRange.max + tolLevel)`.
  - The default value is 0.01.
  - For experimentally determined data, the tolerance level is suggested to be larger to match the uncertainties persented in the data set.
  - *\*Note: In version 0.1.2 or before, the tolerance level meant if the distance between two atoms is in the bond length typical value plus or minus the tolerance level, the program will form a bond between these two atoms. The formula for the range was* `(typBondLength - tolLevel, typBondLength + tolLevel)`. *The default value in these versions was 0.1.*
- Bond angle tolerance ratio (Optional)
  - You'll be prompted to enter a desired value if you want to customize the tolerance ratio used in bond angle filters. Only values between 0 and 1 are allowed.
  - The default value is 0.1.
  - For larger and more complex molecules, the bond angle tolerance ratio is suggested to be increased to bigger values like 0.15 or 0.2 as the bond angles in larger and more complex structures are less predictable.
- Rounded digits of positions after decimal (Optional)
  - You'll be prompted to enter a desired value if you want to customize the number of digits preserved after rounding the position vector of the atoms. The rounding level is suggested to be significantly smaller than the major component(s) of the position vector.
  - The default value is 2.
- Trim level of positions in angstrom (Optional)
  - You'll be prompted to enter a desired value if you want to customize the trim level used to trim down the component of the position vector of an atom to zero if the absolute value of that component is less than the trim level. The trim level is suggested to be siginificantly smaller than the major component(s) of the position vector.
  - The default value is 0*.
    - \*Notice that even the trim level is set to be zero, trimming down still happens based on the rounded digits after decimal. For example, if the rounded digits after decimal is set to be 2, then any position with absolute value less than 0.005 will be "trimmed down" to zero.

### Discussion

As tested on computation-capable platforms, for molecules containing no more than 20 non-hydrogen atoms, the program is able to complete the computation in a reasonable amount of time (mostly less 10 minutes). Some computation time and number of results are listed for reference (tested with CPU [i7-8700B](https://ark.intel.com/content/www/us/en/ark/products/134905/intel-core-i7-8700b-processor-12m-cache-up-to-4-60-ghz.html), with commit [0075521](https://github.com/jerry0317/JYMoleculeTool-Swift/commit/0075521)).\*

|Molecule|Non-H Atoms|Structures in Result|**Bond Graphs in Result**|Lewis Structures in Result|**Computation Time (s)**|
|---|---|---|---|---|---|
|[1,2-propanediol](https://pubchem.ncbi.nlm.nih.gov/compound/1030)|5|32|32|1|0.0139|
|[Benzene](https://pubchem.ncbi.nlm.nih.gov/compound/241)|6|12|216|between 4 and 108|0.0879|
|[Alpha Pinene](https://pubchem.ncbi.nlm.nih.gov/compound/6654)|10|132|148|between 7 and 23|0.8936|
|[Aspirin](https://pubchem.ncbi.nlm.nih.gov/compound/2244)|13|124|618|between 19 and 120|18.382|
|[Branched laurylphenol](https://pubchem.ncbi.nlm.nih.gov/compound/22833469)|17|1008|9534|between 6 and 140|1252.1|
|[Isomorphine](https://pubchem.ncbi.nlm.nih.gov/compound/44246529)|21|10638|34267|between 291 and 12929|14713|
|[Monoacetyl-alpha-isomorphine](https://pubchem.ncbi.nlm.nih.gov/compound/5745678)|24|7980|36980|between 116 and 6253|84726|

\**Detailed results may be found [here](https://github.com/jerry0317/JYMoleculeTool-Results/tree/master/Structure%20Finder/results).*

As the first atom is arbitrarily fixed, the total number of structural combinations for *k* non-hygrogen atoms should be *8<sup>k-1</sup>*. After optimization in algorithms, the runtime complexity of the program should be *O(n logn)*, where *n = 8<sup>k-1</sup>*. Therefore, in terms of *k*, the runtime complexity is basically *2<sup>O(k)</sup>*, which grows exponentially with the increase of number of non-H atoms.

According to the tests, the program is able to complete most of the computations for molecules containing no more than 20 non-hydrogen atoms in less than 10 minutes. The limit is extended to around 23 if the computation time is allowed to be less than one day. Under current test, **the upper limit of the number of non-hydrogen atoms in the molecules is 24**, which takes over 36 hours (a day and a half) to complete the computation. Also note that an extensive amount of memory is needed for computations of large molecules (20+ non-H atoms).

## ABC Tool
This is a tool for implementing [Kraitchman's equations](https://doi.org/10.1119/1.1933338) (J. Kraitchman, *Am. J. Phys.*, **21**, 17 (1953)) to find the absolute values of the position vector (components) of each atoms in the molecule. The program takes data of A,B,C (rotational constants) of the original molecule and the ones after single isotopic substitution.

### Dependencies
The tool uses library `JYMTBasicKit`.

### Usage
- Download the executable from the [release](https://github.com/jerry0317/JYMoleculeTool-Swift/releases/latest).
- Alternatively, run the program directly by
```
swift run -c release JYMT-ABCTool
```
- Or compile the executable by
```
swift build --product JYMT-ABCTool -c release; mv ./.build/release/JYMT-ABCTool JYMT-ABCTool
```
and run the executable by
```
./JYMT-ABCTool
```

### Input
The tool takes a `.sabc` plain-text file as input for the rotational constants and the total mass of the original molecule, and the rotational constants and the substituted atom for each single isotopic substitution. The `.sabc` file looks like below.

```
10696.0950    4051.0323    2994.6632    76.051
Comment line
10695.7310    4043.1721    2990.3393    13    C
10565.6850    4033.4314    2974.8143    13    C
10517.4110    3888.3322    2891.4293    18    O
10018.3875    4035.1737    2930.5332    18    O
10695.7526    3834.7553    2874.8073    18    O
```

(Source: Hasegawa, Hiroshi, Osamu Ohashi, and Ichiro Yamaguchi. "Microwave spectrum and conformation of glycolic acid." *Journal of Molecular Structure* 82.3-4 (1982): 205-211.)

- The first line of the file consists of the three rotational constants A, B, and C *with unit in Megahertz (MHz)*, separated by blank spaces, followed by the total mass of the molecule *with unit in amu*.
- The second line is an optional comment line. It can be blank, but the line must exist.
- Starting from the third line to the last are the information of single isotopic substitution. Each line consists of the three rotational constants A, B, and C *with unit in Megahertz (MHz)* after single isotopic substitution, followed by the mass number of the substituted element (for example, `13` for carbon-13), and the substituted element. Each block of information is separated by blank spaces.

(Note: The actual file extension does not need to be `.sabc`. However, the format must be correct for the tool to work.)

### Output
The tool will print the output to the console, and there is an option to save the results as an `.xyz` file.

### Options
- SABC file path **(Required)**
  - You will be prompted to enter the input sabc file path. You can either enter the relative/absolute file path or drag the file to the console.
- XYZ exporting path (Optional)
  - If you want to save the results, please enter/drag the folder where you want to save the results in.
  - If you don't want to save the results, just leave it empty.

### Discussion

See discussion of the imaginary coordinate issue [here](#discussion-2).

## ABC Calculator
ABC Calculator is a tool to calculate the rotational constants A, B, and C from the structural information (XYZ). It is basically the inverse process of ABC Tool.

This tool utilizes `JYMTAdvancedKit`, which depends on the interoperability bewteen Swift and Python to utilize the [NumPy](https://numpy.org) library to calculate the advanced matrix linear algebra.

Single/multiple isotopic substitutions are also calculated (including hydrogen atoms) based on the structural information. The program will assume the most common isotopologue as the parent molecule, and use the second most common isotope for each element in isotopic substitutions. This tool uses the same calculation module for isotopic substitutions as MIS Calculator.

### Dependencies
The tool uses libraries `JYMTBasicKit` and `JYMTAdvancedKit`.

\*Note: The tool also used `NumPy` library with Python 3. Thus Python 3 along with `NumPy` are required to be installed in the environment.

### Usage
- Download the executable from the [release](https://github.com/jerry0317/JYMoleculeTool-Swift/releases/latest).
- Alternatively, run the program directly by
```
swift run -c release JYMT-ABCCalculator
```
- Or compile the executable by
```
swift build --product JYMT-ABCCalculator -c release; mv ./.build/release/JYMT-ABCCalculator JYMT-ABCCalculator
```
and run the executable by
```
./JYMT-ABCCalculator
```

*Note: Make sure the environment installed Swift 5.1. The Swift 5.0 compiler won't compile as there will be some errors.*

### Input
The tool takes a `.xyz` file as input for the known absolute values (or uncertain-signed values) of positions |x|, |y|, and |z| for each atom in the molecule *with unit in angstrom*. The sign of each value **must be correct** because the tool directly takes the Cartesian coordinates information in the file as the actual structural information. The `.xyz` file looks like below.

```
4

C   -5.43  2.04  -0.14
O   -3.44  3.38  -0.19
C   -3.91  2.04  -0.11
C   -3.37  1.4  1.16
```

*Note: If the molecule has hydrogen atoms in the structure, then the correct Cartesian coordinates information of hydrogen atoms must be included in the xyz file.*

### Output

The tool will directly print the output to the console, and there is an option to save the results as a `.txt` file.. The output contains the calculated rotational constants with unit in megahertz (MHz).

### Options
- XYZ file path **(Required)**
  - You will be prompted to enter the input xyz file path. You can either enter the relative/absolute file path or drag the file to the console.
- log exporting path (Optional)
  - If you want to save the results, please enter/drag the folder where you want to save the results in.
  - If you don't want to save the results, just leave it empty.
- Maximum depth (Optional)
  - The maximum number of atoms that the program will predict for isotopic substitutions. For example, if the maximum depth is set as `3`, then the program will perform single, double, and triple isotopic substitutions.
  - If the maximum depth is set as `0`, then no substitutions will be performed.
  - The default value is 1.

## MIS Calculator

MIS Calculator is tool to calculate the rotational constants information for multiple isotopic substitutions. The data comes from single isotopic substitutions (`sabc` file), *while `.xyz`, `.mol` are planned to be added in the future.*

The program predicts the rotational constants under multiple isotopic substitutions from the given single isotopic substitution information (or data of the molecular structure). The outcomes are not expected to be unique if the structural information is not determined in the data source (for example, from `sabc` or un-signed `.xyz` files), but the program should perform as well as [Structure Finder](#structure-finder) in terms of reduction efficiency.

Use the same module as [ABC Tool](#abc-tool), the program implements [Kraitchman's equations](https://doi.org/10.1119/1.1933338) (J. Kraitchman, *Am. J. Phys.*, **21**, 17 (1953)) to find the absolute values of the position vector (components) of each atoms in the molecule.

In principle, this tool is a convenient combination of ABC Tool, Structure Finder, and ABC Calculator in series. It reflects a typical lab workflow that utilizes this set of tools.

The program will utilize `JYMTAdvancedKit`, which depends on the interoperability bewteen Swift and Python to utilize the `NumPy` library to calculate the advanced matrix linear algebra.

**This tool is still in early development.** Calculation might not reflect the accurate scenario and several researches of physical theories behind the program are in progress to optimize the results.

### Dependencies

The tool uses libraries `JYMTBasicKit` and `JYMTAdvancedKit`.

\*Note: The tool also used `NumPy` library with Python 3. Thus Python 3 along with `NumPy` are required to be installed in the environment.

### Usage

- Download the executable from the [release](https://github.com/jerry0317/JYMoleculeTool-Swift/releases/latest).
- Alternatively, run the program directly by

```
swift run -c release JYMT-MISCalculator
```

- Or compile the executable by

```
swift build --product JYMT-MISCalculator -c release; mv ./.build/release/JYMT-MISCalculator JYMT-MISCalculator
```

and run the executable by

```
./JYMT-MISCalculator
```

### Input

The tool takes a `.sabc` plain-text file as input for the rotational constants and the total mass of the original molecule, and the rotational constants and the substituted atom for each single isotopic substitution. The `.sabc` file looks like below.

```
10696.0950    4051.0323    2994.6632    76.051
Comment line
10695.7310    4043.1721    2990.3393    13    C
10565.6850    4033.4314    2974.8143    13    C
10517.4110    3888.3322    2891.4293    18    O
10018.3875    4035.1737    2930.5332    18    O
10695.7526    3834.7553    2874.8073    18    O
```

(Source: Hasegawa, Hiroshi, Osamu Ohashi, and Ichiro Yamaguchi. "Microwave spectrum and conformation of glycolic acid." *Journal of Molecular Structure* 82.3-4 (1982): 205-211.)

- The first line of the file consists of the three rotational constants A, B, and C *with unit in Megahertz (MHz)*, separated by blank spaces, followed by the total mass of the molecule *with unit in amu*.
- The second line is an optional comment line. It can be blank, but the line must exist.
- Starting from the third line to the last are the information of single isotopic substitution. Each line consists of the three rotational constants A, B, and C *with unit in Megahertz (MHz)* after single isotopic substitution, followed by the mass number of the substituted element (for example, `13` for carbon-13), and the substituted element. Each block of information is separated by blank spaces.

(Note: The actual file extension does not need to be `.sabc`. However, the format must be correct for the tool to work.)

### Output

The tool will print the output to the console, and there is an option to save the results as a `.txt` file.

### Options

- SABC file path **(Required)**
  - You will be prompted to enter the input sabc file path. You can either enter the relative/absolute file path or drag the file to the console.
- log exporting path (Optional)
  - If you want to save the results, please enter/drag the folder where you want to save the results in.
  - If you don't want to save the results, just leave it empty.
- Maximum depth (Optional)
  - The maximum number of atoms that the program will predict for isotopic substitutions. For example, if the maximum depth is set as `3`, then the program will perform single, double, and triple isotopic substitutions.
  - The default value is 2.

### Discussion

There is a known problem (both in MIS Calculator and ABC Tool, as they rely on the same algorithm) that a square root operation on negative numbers might occur when implementing Kraitchman's equations when the input data is not perfectly accurate. When this problem raises, the program will print the following message to the console *(as an example)*

```
WARNING: Imaginary coordinate 0.0161i appeared. Rounded to zero. (ABC dev: 7.63kHz)
```

and round the corresponding coordinate to zero. The ABC deviation provides the information that how large the error can be in the input rotational constants to ''make'' the coordinate zero.

If the imaginary number is small, then the problem is not significantly serious in structure determination (when use with Structure Finder). However, it would be serious in predicting isotopic substitutions as the rotational constants and corresponding parameters are extraordinarily sensitive to the accuracy of the data source. The single substitution might be unmatched between the input data and the re-constructed data from the program since the program rounds the imaginary coordinates to zero. For example, for the following parent molecule and single isotopic substitution

```
[Parent Molecule]
PM    A: 8572.0553    B: 3640.1063   C: 2790.9666   Mass: 76.09
[Single Isotopic Substitution]
...
C2    A: 8555.9200    B: 3631.1660   C: 2787.5640   Isotope: 13
...
```

the following warning will be raised during the calculation

```
WARNING: Imaginary coordinate 0.0697i appeared. Rounded to zero. (ABC dev: 252.13kHz)
```

and the following coordinates with be passed to the later calculations after structure filtering

```
...
C2   [-0.47733, 0.00000, -0.34254]
...
```

As observed, the rounded coordinates don't reflect the actual position of the atom in the molecule because when the program reconstructs the single isotopic substitution, it yields a different result than the input source:

```
...
C2    A: 8555.225504    B: 3631.165991   C: 2787.489864
...
```

In practical, this problem is worrying because it makes the predictions from the tool less reliable even there are no imagninary coordinates presented. Certain physical theories underlying the program might cause this "imgainary self-contradiction" as some effects including vibrations and centrifugal distortions are not fully considered in the calculations. Deeper reseraches are in progress in attempt to solve the problem, or, at least to minimize the error presented in this problem.

As of the current reserach goes, it was found that this problem of imaginary coordinates were common and often happened when the atom was near the principal axes or the principal plane of the molecule. The root of this problem comes from the neglection of the change of the rovibrational effect on the molecule before/after the isotopic substitutions. This was the assumption of Kraitchman's equations, which is the underlying theory of the algorithm used in this program. The structure derived from Kraitchman's equation, which is usually named *r<sub>s</sub>*, is one of the most popular derived data in rotational spectroscopy because it requires less amount of experimental data and gives a relatively accurate estimation of the structure. However, the reliability of *r<sub>s</sub>* decreases as the atom becomes closer to the principal axes or the principal plane, which is the major issue presented here.

Other popular alternatives including *r<sub>m</sub>*, *r<sub>c</sub>*, *r<sub>m</sub><sup>ρ</sup>* are usually used to take the change in rovibrational effect and inertial defects into account. But these parameters require a massive amount of data (for example, *r<sub>m</sub>* requires a complete set of single isotopic substitutions or more) which are unrealistic in the actual lab environment, especially for large molecules. Therefore, we must look for an intermediate parameter bewteen *r<sub>s</sub>* and *r<sub>m</sub>* that requires less amount of data than *r<sub>m</sub>*, but provides a more accurate estimate of structure than *r<sub>s</sub>*. More researches on this topic are in progress.

## Acknowledgement

This set of tools are affliated with [Patterson Group](https://pattersongroup.physics.ucsb.edu) at University of California, Santa Barbara and built with assistance from Professor Dave Patterson. Our appreciation extends to the colleagues for help to build this set of tools. Special thanks to Larry Li for assistance in runtime optimization when writing the Structure Finder.

## References

*(In no particular order)*

- Gordy, Walter, and Robert Lee Cook. *Microwave molecular spectra*. Wiley, 1984.
- Schwendeman, R. H. *Structural parameters from rotational spectra*. National Academy of Science, 1974.
- Lovas, Francis J., et al. "Microwave spectrum of 1, 2-propanediol." *Journal of Molecular Spectroscopy* 257.1 (2009): 82-93.
- Costain, CiC. "Further comments on the accuracy of rs substitution structures." *Trans. Am. Crystallogr. Assoc* 2 (1966): 157-164.
- Gillespie, Ronald J., and István Hargittai. *The VSEPR model of molecular geometry*. Courier Corporation, 2013.
- Rodger, Alison, and Mark Rodger. *Molecular geometry*. Butterworth-Heinemann, 2014.
- Avogadro: an open-source molecular builder and visualization tool. Version 1.20. http://avogadro.cc/
- Rudolph, Heinz Dieter, and Jean Demaison. "Determination of the structural parameters from the inertial moments." *Equilibrium Molecular Structures*. CRC Press, 2016. 139-172.
- Kraitchman, J. "Determination of molecular structure from microwave spectroscopic data." *American Journal of Physics*21.1 (1953): 17-24.
- Watson, James KG, Artur Roytburg, and Wolfgang Ulrich. "Least-squares mass-dependence molecular structures." *Journal of molecular spectroscopy* 196.1 (1999): 102-119.
- Harmony, M. D., and W. H. Taylor. "The use of scaled moments of inertia for structural calculations." *Journal of Molecular Spectroscopy* 118.1 (1986): 163-173.
- Harmony, Marlin D. "The equilibrium carbon–carbon single‐bond length in ethane." *The Journal of chemical physics* 93.10 (1990): 7522-7523.
- Harmony, Marlin D. "The elusive equilibrium bond length in organic polyatomic molecules: finally obtainable from spectroscopy?." *Accounts of chemical research* 25.8 (1992): 321-327.
- Berry, Rajiv J., and Marlin D. Harmony. "The use of scaled moments of inertia in experimental structure determinations: Extension to simple molecules containing hydrogen." *Journal of Molecular Spectroscopy* 128.1 (1988): 176-194.
- Nakata, Munetaka, and Kozo Kuchitsu. "Estimation of the equilibrium structures of polyatomic molecules using isotopic differences in vibrationally averaged structures." *Journal of molecular structure* 320 (1994): 179-192.
- Berry, Rajiv J., and Mariin D. Harmony. "The use of scaled moments of inertia in experimental structure determinations of polyatomic molecules." *Structural Chemistry* 1.1 (1990): 49-59.
- Typke, V. "Utilization of simultaneous multiple substitutions in the determination of the rs structure." *Journal of Molecular Spectroscopy* 69.2 (1978): 173-178.
- Demaison, J., and H. D. Rudolph. "When is the substitution structure not reliable?." *Journal of Molecular Spectroscopy* 215.1 (2002): 78-84.
- Tam, H. S., and Marlin D. Harmony. "Study of molecular structure of polyatomic molecules using scaled moments of inertia." *The Journal of Physical Chemistry* 95.23 (1991): 9267-9272.
- Coles, D. K., and R. H. Hughes. "Microwave spectra of nitrous oxide." *Phys. Rev* 76 (1949): 178.
- Watson, James KG. "The estimation of equilibrium molecular structures from zero-point rotational constants." *Journal of Molecular Spectroscopy* 48.3 (1973): 479-502.
- Morino, Yonezo, Kozo Kuchitsu, and Takeshi Oka. "Internuclear distance parameters." *The Journal of Chemical Physics* 36.4 (1962): 1108-1109.
- Herschbach, Dudley R., and Victor W. Laurie. "Influence of Vibrations on Molecular Structure Determinations. I. General Formulation of Vibration—Rotation Interactions." *The Journal of Chemical Physics* 37.8 (1962): 1668-1686.
- Laurie, Victor W., and Dudley R. Herschbach. "Influence of vibrations on molecular structure determinations. II. Average structures derived from spectroscopic data." *The Journal of Chemical Physics* 37.8 (1962): 1687-1693.
- Herschbach, Dudley R., and Victor W. Laurie. "Influence of vibrations on molecular structure determinations. III. Inertial defects." *The Journal of Chemical Physics* 40.11 (1964): 3142-3153.
- Abdulghany, A. R. "Generalization of parallel axis theorem for rotational inertia." *American Journal of Physics* 85.10 (2017): 791-795.
- Allen, Frank H., et al. "Tables of bond lengths determined by X-ray and neutron diffraction. Part 1. Bond lengths in organic compounds." *Journal of the Chemical Society, Perkin Transactions 2* 12 (1987): S1-S19.
- Hargittai, Istvan, and B. Chamberland. "The VSEPR model of molecular geometry." *Computers & Mathematics with Applications* 12.3-4 (1986): 1021-1038.
- Kivelson, Daniel, E. Bright Wilson Jr, and David R. Lide Jr. "Microwave Spectrum, Structure, Dipole Moment, and Nuclear Quadrupole Effects in Vinyl Chloride." *The Journal of Chemical Physics* 32.1 (1960): 205-209.
- Demaison, J., et al. "Experimental and Ab Initio equilibrium structures of cis-thionylimide, HNSO: estimation of the laurie correction." *Structural Chemistry* 12.1 (2001): 1-13.
- Kisiel, Z. "Assignment and analysis of complex rotational spectra." *Spectroscopy from Space*. Springer, Dordrecht, 2001. 91-106.
- [Programs for Rotational Spectroscopy](http://www.ifpan.edu.pl/~kisiel/prospe.htm)
- Nōsberger, P., A. Bauder, and Hs H. Günthard. "A versatile method for molecular structure determinations from ground state rotational constants." *Chemical Physics* 1.5 (1973): 418-425.
- Oka, Takeshi. "Microwave Spectrum of Formaldehyde II. Molecular Structure in the Ground State." *Journal of the Physical Society of Japan* 15.12 (1960): 2274-2279.
- Lockley, Thomas JL, et al. "Detection and analysis of a new conformational isomer of propan-1, 2-diol by Fourier transform microwave spectroscopy." *Journal of molecular structure* 612.2-3 (2002): 199-206.
- Neeman, Elias M., Juan Ramón Avilés Moreno, and Thérèse R. Huet. "The gas phase structure of α-pinene, a main biogenic volatile organic compound." *The Journal of chemical physics* 147.21 (2017): 214305.
- Lide Jr, David R., and Daniel Christensen. "Molecular structure of propylene." *The Journal of Chemical Physics* 35.4 (1961): 1374-1378.
- Obenchain, Daniel A., et al. "Rotational spectrum of three conformers of 3, 3-difluoropentane: Construction of a 480 MHz bandwidth chirped-pulse Fourier-transform microwave spectrometer." *Journal of Molecular Spectroscopy* 261.1 (2010): 35-40.
- Blom, C. E., and A. Bauder. "Structure of glycolic acid determined by microwave spectroscopy." *Journal of the American Chemical Society* 104.11 (1982): 2993-2996.
- Pierce, Louis. "Note on the use of ground-state rotational constants in the determination of molecular structures." *Journal of Molecular Spectroscopy* 3.1-6 (1959): 575-580.
- Krisher, Lawrence C., and Louis Pierce. "Second Differences of Moments of Inertia in Structural Calculations: Application to Methyl‐Fluorosilane Molecules." *The Journal of Chemical Physics* 32.6 (1960): 1619-1625.
- Hanwell, Marcus D., et al. "Avogadro: an advanced semantic chemical editor, visualization, and analysis platform." *Journal of cheminformatics* 4.1 (2012): 17.