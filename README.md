![](https://github.com/senselogic/SNIP/blob/master/LOGO/snip.png)

# Snip

Code snippet extractor.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 snip.d
```

## Command line

```
snip <input file path> <output folder path>
```

### Example

```bash
snip input_text.txt OUTPUT_FOLDER/
```

Extracts the code snippet files.

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
