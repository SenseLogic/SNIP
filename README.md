![](https://github.com/senselogic/SNIP/blob/master/LOGO/snip.png)

# Snip

Code snippet joiner and splitter.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 snip.d
```

## Command line

```
snip --join <input folder path> <output file path>
snip --split <input file path> <output folder path>
```

### Example

```bash
snip --join INPUT_FOLDER/ output_text.txt
snip --split input_text.txt OUTPUT_FOLDER/
```

Extracts the code snippet files.

## Version

0.2

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
