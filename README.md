# JYMoleculeTool-Swift
The project provides tools for analyzing molecules based on physical and chemical equations.

The project currently includes the following tools:
- Structure Finder
- ABC Tool
- ABC Calculator *(Under early development)*

## Structure Finder
Structure Finder provides the ability to calculate the possible structures of a molecule from the known absolute values (or uncertain-signed values) of positions |x|, |y|, and |z| for each atom in the molecule. The latter data can be obtained via the single isotope substitution based on Kraitchman's equations.

### Dependencies
The tool uses library `JYMTBasicKit`.

### Requirements
The code is written on Swift 5.1, thus any compilation should be performed on the compiler of Swift 5.1 or newer versions. The executables should be working on environments that has Swift 5.1 installed.

|System Version|Swift Version|Status|
|---|---|---|
|macOS 10.14.5|Swift 5.1|Verified|
|macOS 10.15 beta|Swift 5.1|Verified|
|Ubuntu 18.04.2 LTS|Swift 5.1|Verified|

To learn how to install Swift, please [visit here](https://swift.org/download/#snapshots). In the "Snapshots" section, select **Swift 5.1 Development**.

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
This is a tool for implementing [Kraitchman's equations](https://doi.org/10.1119/1.1933338) (J. Kraitchman, *Am. J. Phys.*, **21**, 17 (1953)) to find the absolute values of the position vector (components) of each atoms in the molecule. The program takes data of A,B,C (rotational constants) of the original molecule and the ones after single isotopic substitution.

### Dependencies
The tool uses library `JYMTBasicKit`.

### Requirements
The code is written on Swift 5.1, thus any compilation should be performed on the compiler of Swift 5.1 or newer versions. The executables should be working on environments that has Swift 5.1 installed.

|System Version|Swift Version|Status|
|---|---|---|
|macOS 10.14.5|Swift 5.1|Verified|
|macOS 10.15 beta|Swift 5.1|Verified|
|Ubuntu 18.04.2 LTS|Swift 5.1|Verified|

To learn how to install Swift, please [visit here](https://swift.org/download/#snapshots). In the "Snapshots" section, select **Swift 5.1 Development**.

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
The tool takes a `.sabc` file as input for the rotational constants and the total mass of the original molecule, and the rotational constants and the substituted atom for each single isotopic substitution. The `.sabc` file looks like below.

```
1936.55844    1228.63567    1127.02099    120
Comment line
1929.20910    1226.98871    1125.97313    13.003355    C
1935.85590    1222.67766    1121.80384    13.003355    C
1928.89130    1221.20643    1119.50458    13.003355    C
1911.05500    1227.55856    1118.84796    13.003355    C
1926.66350    1226.18046    1121.82067    13.003355    C
1935.45920    1225.01889    1123.79430    13.003355    C
1915.87640    1221.12368    1125.75989    13.003355    C
1912.26360    1217.63188    1123.33119    13.003355    C
1929.98960    1211.19930    1110.61206    13.003355    C
1924.63160    1209.41975    1106.97962    13.003355    C
```

(Source: Neeman, Avilés Moreno, and Huet, J. Chem. Phys. **147**, 214305 (2017).)

- The first line of the file consists of the three rotational constants A, B, and C *with unit in Megahertz (MHz)*, separated by blank spaces, followed by the total mass of the molecule *with unit in amu*.
- The second line is an optional comment line. It can be blank, but the line must exist.
- Starting from the third line to the last are the information of single isotopic substitution. Each line consists of the three rotational constants A, B, and C *with unit in Megahertz (MHz)* after single isotopic substitution, followed by the substituted mass *with unit in amu*, and the substituted element. Each block of information is separated by blank spaces.

(Note: The actual file extension does not need to be `.sabc`. However, the format must be correct for the tool to work.)

### Output
The tool will print the output to the console, and there is an option to save the results as an `.xyz` file.

### Options
- SABC file path **(Required)**
  - You will be prompted to enter the input sabc file path. You can either enter the relative/absolute file path or drag the file to the console.
- XYZ exporting path (Optional)
  - If you want to save the results, please enter/drag the folder where you want to save the results in.
  - If you don't want to save the results, just leave it empty.

## ABC Calculator
ABC Calculator will be a new tool to calculate the rotational constants A, B, and C from the structural information (XYZ). It is basically the inverse process of ABC Tool.

The program will utilize `JYMTAdvancedKit`, which depends on the interoperability bewteen Swift and Python to utilize the [NumPy](https://numpy.org) library to calculate the advanced matrix linear algebra.

**This tool is still in early development.** Keep an eye on it.
