# Benchmark-Toolkit

A utility and development library for benchmarking under specific conditions.

## Features
   - **Dynamic Memory & Timing Statistics**: Provides dynamic memory and timing statistics with easy-to-understand output.
   - **Customizable Configuration Options**: Easily modify configuration settings on the fly using console variables.
   - **Easily Utilized Functions & Commands**: Includes multiple API functions and an easy-to-use console command interface.

## Getting Started

### Prerequisites

This library is exclusive to Garry's Mod, and you are expected to have a baseline understanding of the following:

- [Garry's Mod](https://store.steampowered.com/app/4000/Garrys_Mod/).
- Basic knowledge of [Lua 5.1](https://lua.org/).
- Basic knowledge of [LuaJIT 2.0.4](https://luajit.org/).

### Installation

You can install by embedding in an already existing addon or by:

1. Cloning the repository:
   ```bash
   git clone https://github.com/ryanoutcome20/Benchmark-Toolkit.git
   ```
2. Dragging the source Lua file into the directory: "*Steam\steamapps\common\GarrysMod\garrysmod\lua*".
3. Executing the code via the console command: "*lua_openscript_cl benchtk.lua*" or "*lua_openscript benchtk.lua*".

### User Usage

There are a few console variables you can access:

- `btk_count`: This variable will control the amount of times to run the code or file.
- `btk_decimals`: This variable will control the precision of the rounding on both garbage and timings.

There are a few console commands you can use these console commands (suffix cl for clientside)::

- `btk_openscript`: This will benchmark a script relative to the Lua folder.
- `btk_run`: Runs code direct from the command line.
- `btk_copy`: Copies your last benchmark results to clipboard in JSON format.
- `btk_demo`: Runs a demo to showcase how the benchmark results look.
- `btk_exec`: Executes a function relative to the global variable table (if you don't know what this is then it is best to ignore it).

### Developer Usage

The API offers several functions, and the entire table is globalized and returned at the end of the file (BTK). I **highly** recommend you take a look inside of the file to get a feel of how everything functions (as there is extensive documentation available inside of the file). A few notable functions are:

- `BTK:Boot(function Func, vararg ...)`: Runs the main benchmarking process.  
  - Modify console variables via the `Console` table or `RunConsoleCommand`.  
  - Returns a summary.
- `BTK:Last()`: Generates and returns the summary of the last benchmark cycle.

### Example

Here’s a simple example of benchmarking a function:

```lua
local function Sample( )
    -- Returns a sum from 1-1000

    local x = 0

    for i = 1, 1000 do
        x = x + i
    end
end

BTK:Boot( Sample )
```

### Contributing

Contributions are welcome! To suggest or add a new feature, submit an issue or pull request.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](./LICENSE) file for more details.
