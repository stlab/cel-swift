# cel-swift

A Swift library for [description of your project].

## Requirements

- macOS 15 (Sonoma) or later
- Swift 6.0 or later
- Visual Studio Code or Cursor

## Setup for VSCode/Cursor

This project is configured for development in VSCode or Cursor. The following extensions are recommended:

1. **Swift Language** extension by Swift Server Work Group (sswg.swift-lang)
2. **CodeLLDB** extension for debugging (vadimcn.vscode-lldb)

You can install these extensions by running:

```bash
code --install-extension sswg.swift-lang
code --install-extension vadimcn.vscode-lldb
```

## Building and Testing

You can use the following VSCode tasks:

- **⇧⌘B** or **Terminal > Run Build Task...** - Build the project
- **⇧⌘T** or **Terminal > Run Test Task...** - Run tests
- **Tasks: Run Task > swift: Clean** - Clean the build
- **Tasks: Run Task > swift: Build (Release)** - Build in release mode

## Debugging

Launch configurations are provided for debugging tests. Select the **Debug Tests** configuration from the Run and Debug sidebar.

## Project Structure

- `Sources/cel-swift/` - Source code for the library
- `Tests/cel-swiftTests/` - Unit tests

## Note

The current codebase has some compilation errors that need to be fixed. You can use the tasks in VSCode to identify and fix these issues as you continue development. 
