# zhoufang-joe/brew

A Homebrew tap containing custom formulas for various tools and utilities.

## Available Formulas

### FileToJPG
A tool that converts files to JPG format and extracts files from JPG images.

**Utilities provided:**
- **FileToJPG**: Convert any file to JPG format
- **JPGToFile**: Extract files that were previously converted to JPG format

## Installation

### Prerequisites
- macOS with Homebrew installed

### Add the Tap

First, add this tap to your Homebrew:
```bash
brew tap zhoufang-joe/brew
```

### Install Formulas

Once the tap is added, you can install any of the available formulas:

```bash
# Install FileToJPG
brew install filetojpg

# Install other formulas (as they become available)
# brew install other-formula-name
```

### Alternative: Install directly from formula files

If you have the formula files locally, you can install them directly:

```bash
# Install a specific formula file
brew install ./filetojpg.rb
```

## Usage

### FileToJPG

After installing the FileToJPG formula, you'll have access to two commands:

#### Convert a file to JPG
```bash
FileToJPG yourfile.txt
```
This will create `yourfile.txt.JPG`

#### Extract a file from JPG
```bash
JPGToFile yourfile.txt.JPG
```
This will extract the original `yourfile.txt`

## Uninstallation

### Remove specific formulas

To remove a specific formula from your system:

```bash
# Remove FileToJPG
brew uninstall filetojpg

# Remove other formulas
# brew uninstall other-formula-name
```

### Remove the entire tap

To remove the entire tap and all its formulas:
```bash
brew untap zhoufang-joe/brew
```

## Verification

To verify the installation worked correctly:

```bash
# Check if the commands are available
which FileToJPG
which JPGToFile

# View help/version information
FileToJPG --help
JPGToFile --help
```

## Troubleshooting

### Installation Issues

1. **Build failures**: Ensure you have an active internet connection for Go module downloads
2. **Permission issues**: Make sure Homebrew has proper permissions in `/usr/local` (Intel) or `/opt/homebrew` (Apple Silicon)

### Common Commands

```bash
# Check formula info
brew info filetojpg

# List all installed formulas
brew list

# List formulas from this tap
brew list | grep zhoufang-joe

# Update Homebrew and all formulas
brew update && brew upgrade

# Update only formulas from this tap
brew upgrade zhoufang-joe/brew/filetojpg

# Clean up old versions
brew cleanup filetojpg
```

## Contributing

To add new formulas to this tap:

1. Create a new `.rb` file in the root directory
2. Follow Homebrew formula conventions
3. Test the formula locally: `brew install ./your-formula.rb`
4. Submit a pull request

## License

Formulas in this tap may have different licenses. Check individual formula files for specific license information.

## Links

- **This Tap**: https://github.com/zhoufang-joe/brew
- **FileToJPG Source**: https://github.com/zhoufang-joe/FileToJPG
- **Homebrew Documentation**: https://docs.brew.sh/
- **Creating Homebrew Formulas**: https://docs.brew.sh/Formula-Cookbook 