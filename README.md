# GoRunScript

[![Go Reference](https://pkg.go.dev/badge/github.com/cdvelop/gorunscript.svg)](https://pkg.go.dev/github.com/cdvelop/gorunscript)

A lightweight Go library for seamlessly executing Bash scripts from your Go applications with powerful features for handling arguments, output, and error management.

## Features

- 🚀 Execute Bash scripts directly from Go code
- 🔄 Pass arguments to your scripts easily
- 📊 Capture exit codes, output text, and error information
- 🛠️ Support for custom functions and utilities in your scripts
- 🧪 Well-tested with comprehensive test coverage

## Installation

```bash
go get github.com/cdvelop/gorunscript
```

## Quick Start

```go
package main

import (
    "fmt"
    "github.com/cdvelop/gorunscript"
)

func main() {
    // Create a new Bash script runner
    runner := gorunscript.NewBashRunner()
    
    // Execute a script with arguments
    exitCode, output, err := runner.ExecuteScript("my-script", "arg1", "arg2")
    
    // Handle the results
    if err != nil {
        fmt.Printf("Error: %v (Exit code: %d)\n", err, exitCode)
        fmt.Printf("Output: %s\n", output)
    } else {
        fmt.Printf("Success! (Exit code: %d)\n", exitCode)
        fmt.Printf("Output: %s\n", output)
    }
}
```

## Usage

### Basic Usage

1. Create a script runner:

```go
// Default runner (searches for scripts in standard locations)
runner := gorunscript.NewBashRunner()

// Or specify a custom project root directory that contains bash_scripts/
runner := gorunscript.NewBashRunnerWithOptions("/path/to/project")
```

2. Execute a script:

```go
exitCode, output, err := runner.ExecuteScript("script-name", "arg1", "arg2")
```

3. Process the results:

```go
if err != nil {
    // Handle error
    log.Printf("Script execution failed: %v", err)
} else {
    // Process successful execution
    log.Printf("Script executed successfully with output: %s", output)
}
```

### Script Organization

Your Bash scripts should be placed in a `bash_scripts` directory in your project root:

```
your-go-project/
├── bash_scripts/
│   ├── script1.sh
│   ├── script2.sh
│   └── functions.sh  (optional shared functions)
└── main.go
```

### Shared Functions

You can create a `functions.sh` file in your `bash_scripts` directory with common utilities that can be used across all your scripts:

```bash
#!/bin/bash
# bash_scripts/functions.sh

# Display success message
success() {
    echo "=>OK $1"
}

# Display error message
error() {
    echo "¡ERROR! $1"
    exit 1
}

# Execute a command safely
execute() {
    echo "Ejecución exitosa del comando: $@"
    "$@" || error "Failed to execute: $@"
}
```

## Advanced Features

### Custom Project Root Detection

The library intelligently detects your project root, but you can always specify it explicitly:

```go
customRunner := gorunscript.NewBashRunnerWithOptions("/custom/project/path")
```

### Working with Exit Codes

```go
exitCode, output, err := runner.ExecuteScript("backup-script")
if exitCode != 0 {
    fmt.Printf("Backup failed with exit code %d\n", exitCode)
}
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
