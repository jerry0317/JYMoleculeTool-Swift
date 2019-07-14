# JYMoleculeTool-Swift
The project provides tools for analyzing molecules based on physical and chemical equations.

The project currently includes the following tools:
- Structure Finder
- ABC Tool **(New project, under development)**

## Structure Finder
Structure Finder provides the ability to calculate the possible structures of a molecule from the known absolute values (or uncertain-signed values) of positions |x|, |y|, and |z| for each atom in the molecule. The latter data can be obtained via the single isotope substitution based on Kraitchman's equations.

### Codes
The tool uses files in folders `JYMT Library` and `JYMT-StructureFinder`.

### Requirements
The code is written on Swift 5.1, thus any compilation should be performed on the compiler of Swift 5.1 or newer versions. The executables should be working on environments that has Swift 5.1 installed.

|System Version|Swift Version|Status|
|---|---|---|
|macOS 10.14.5|Swift 5.1|Verified|
|macOS 10.15 beta|Swift 5.1|Verified|
|Ubuntu 18.04.2 LTS|Swift 5.1|Verified|

To learn how to install Swift, please [visit here](https://swift.org/download/#snapshots). In the "Snapshots" section, select **Swift 5.1 Development**.

### Use
- Download the executable from the release *(Not available yet)*
- or compile by
```
swiftc JYMT\ Library/*.swift JYMT-StructureFinder/*.swift -O -o JYMT-StructureFinder-executable
```
and run the program by
```
./JYMT-StructureFinder-executable
```

*Note: Make sure the environment installed Swift 5.1. The Swift 5.0 compiler won't compile as there will be some errors.*

### Input
The tool takes a `.xyz` file as input for the known absolute values (or uncertain-signed values) of positions |x|, |y|, and |z| for each atom in the molecule *with unit in angstrom*. The sign of each value can be incorrect, but their value (absolute value) must be matched to the ultimate correct structure. The `.xyz` file looks like below.

```
4

C   -5.43  2.04  -0.14
O   -3.44  3.38  -0.19
C   -3.91  2.04  -0.11
C   -3.37  1.4  1.16
```

### Output
The tool will print the output to the console, and there is an option to save the results as `.xyz` files and the log as `.txt` file.

### Options
- XYZ file path **(Required)**
  - You will be prompted to enter the input xyz file path. You can either enter the relative/absolute file path or drag the file to the console.
- XYZ exporting path (Optional)
  - If you want to save the results, please enter/drag the folder where you want to save the results in.
  - If you don't want to save the results, just leave it empty.
- Bond length tolerance level in angstrom (Optional)
  - You'll be prompted to enter a desired value if you want to customize the tolerance level used in bond length filters.
  - The default value is 0.1.
- Bond angle tolerance ratio (Optional)
  - You'll be prompted to enter a desired value if you want to customize the tolerance ratio used in bond angle filters. Only values between 0 and 1 are allowed.
  - The default value is 0.1.
- Rounded digits after decimal (Optional)
  - You'll be prompted to enter a desired value if you want to customize the number of digits preserved after rounding the position vector of the atoms. The rounding level is suggested to be significantly smaller than the major component(s) of the position vector.
  - The default value is 2.

## ABC Tool
This is a program currently **under development** to provide a tool for implementing Kraitchman's equations to find the absolute values of the position vector (components) of each atoms in the molecule.

The program will take data of A,B,C (rotational constants) of the original molecule and the ones after single isotopic substitution.

The goal for the program is to design a tool to make the JYMT-StructureFinder more practical in lab use.
