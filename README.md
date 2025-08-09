# launsh

`launsh` is a cross-platform script launcher with a graphical user interface, configured via a single JSON file.
It helps you organize and run your frequently used shell commands and scripts with a single click.

![Screenshot1](images/Screenshot1.png)
![Screenshot2](images/Screenshot2.png)

## Usage

1. **Install launsh**
   - Download the built executable file from https://github.com/Jumpaku/launsh/releases .

2. **Start launsh**
   - Run the app on your desktop (macOS/Windows), which may require security allowances.

3. **Select Working Directory**
   - Click the `Select Working Directory` button at the top left.
   - Choose a folder containing your `launsh.json` configuration file.

4. **Select and Run Entrypoints**
   - The left panel lists entrypoints defined in `launsh.json`.
   - Click a job to execute the associated command/script.

## Configuration

- Place a `launsh.json` file in your working directory. This file defines the entrypoints you can run.
- The `launsh.json` must follow the JSON schema at https://github.com/Jumpaku/launsh/blob/main/launsh.schema.json .
- See the following example for details on the configuration format.

```json
{
  "$schema": "./launsh.schema.json",
  "entrypoints": {
    "List Current Directory": {
      "description": "Lists files and directories in the current path.",
      "program": "ls",
      "args": [
        "-l",
        "-a"
      ]
    },
    "Greet User": {
      "description": "A sample command that uses environment variables and arguments with parameters.",
      "program": "bash",
      "args": [
        "-c",
        "echo \"Hello, ${USER_NAME}! Today is ${TODAY}.\""
      ],
      "parameter": [
        "USER_NAME"
      ],
      "environment": {
        "TODAY": "Monday"
      },
      "stdout": "stdout.log",
      "stderr": "stderr.log"
    },
    "Run script": {
      "description": "A sample command that uses environment parameters and arguments with parameters.",
      "program": "sh",
      "args": ["./run.sh"]
    }
  }
}
```
