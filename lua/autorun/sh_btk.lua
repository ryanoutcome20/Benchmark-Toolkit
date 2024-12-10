--[[
    ╔╗ ┌─┐┌┐┌┌─┐┬ ┬┌┬┐┌─┐┬─┐┬┌─  ╔╦╗┌─┐┌─┐┬  ┬┌─┬┌┬┐
    ╠╩╗├┤ ││││  ├─┤│││├─┤├┬┘├┴┐   ║ │ ││ ││  ├┴┐│ │ 
    ╚═╝└─┘┘└┘└─┘┴ ┴┴ ┴┴ ┴┴└─┴ ┴   ╩ └─┘└─┘┴─┘┴ ┴┴ ┴ 

    https://github.com/ryanoutcome20/Benchmark-Toolkit
--]]

-- Main Table
BTK = { }

-- =============================================================================
-- Initialize helper functions and variables.
-- =============================================================================

BTK.Colors = {
    [ 'Main' ] = Color( 150, 189, 252 ), 

    [ 'White' ] = Color( 255, 255, 255 ),
    [ 'Black' ] = Color( 0, 0, 0 ),
    [ 'Gray' ]  = Color( 60, 60, 60 ),

    [ 'Red' ]   = Color( 255, 0, 0 ),
    [ 'Green' ] = Color( 0, 255, 0 ),
    [ 'Blue' ]  = Color( 0, 0, 255 ),
}

-- =============================================================================
-- Function to automatically print to the console with the colored logo.
-- @param Text (string): The text to append after the logo.
-- @param vararg: The data to append after the text, usually, debug information.
-- =============================================================================
function BTK:Print( Text, ... )
    if not Text then 
        return 
    end

    MsgC( self.Colors[ 'Gray' ], os.date( '[%H:%M:%S] ' ), self.Colors[ 'Main' ], '[ BTK ] ', self.Colors[ 'White' ], Text, '\n' )
    
    local Data = { ... }
    local Size = #Data

    if Size <= 0 then
        return 
    end

    for i = 1, Size do 
        MsgC( self.Colors[ 'White' ], '        | ', Data[ i ], '\n' )
    end
end

-- =============================================================================
-- Print logo to console.
-- =============================================================================

MsgC( BTK.Colors[ 'Main' ], [[
╔╗ ┌─┐┌┐┌┌─┐┬ ┬┌┬┐┌─┐┬─┐┬┌─  ╔╦╗┌─┐┌─┐┬  ┬┌─┬┌┬┐
╠╩╗├┤ ││││  ├─┤│││├─┤├┬┘├┴┐   ║ │ ││ ││  ├┴┐│ │ 
╚═╝└─┘┘└┘└─┘┴ ┴┴ ┴┴ ┴┴└─┴ ┴   ╩ └─┘└─┘┴─┘┴ ┴┴ ┴ 

https://github.com/ryanoutcome20/Benchmark-Toolkit
]] )

-- =============================================================================
-- Initialize console variables.
-- =============================================================================

BTK.Console = {
    Count = CreateConVar( 'btk_count', 10000, FCVAR_NONE, 'The amount of times to run the code or file.' ),
    Decimal = CreateConVar( 'btk_decimals', 64, FCVAR_NONE, 'The precision of the rounding on both garbage and timings.' ),
}

-- =============================================================================
-- Initialize helper functions.
-- =============================================================================

-- =============================================================================
-- Internal function used to generate a save point with saved information.
-- @return table: A table containing the garbage and timing information of the system.
-- =============================================================================
function BTK:Data( )
    return {
        Garbage = collectgarbage( 'count' ),
        Time = SysTime( )
    }
end

-- =============================================================================
-- Internal function used print the final data at the end of a benchmark.
-- @param Before (number): The before data point.
-- @param After (number): The after data point.
-- @param Config (table): The config table containing the console variable information.
-- @param Name (string): The name to be prefixed at the beginning of the message.
-- =============================================================================
function BTK:Calculate( Before, After, Config, Name )
    local Total = After - Before
    local Average = Total / Config.Count

    self:Print( string.format( '%s Results: \n  | Total: %s\n  | Average: %s\n', 
        Name,
        math.Round( Total, Config.Decimal ),
        math.Round( Average, Config.Decimal )
    ) )
end

-- =============================================================================
-- Initialize main function.
-- =============================================================================

-- =============================================================================
-- Function to start a benchmark.
-- @param Func (function): The function to test.
-- @param vararg: The arguments to pass to the function.
-- @return table: The before dataset containing time and garbage info.
-- @return table: The after dataset containing time and garbage info.
-- =============================================================================
function BTK:Boot( Func, ... )
    assert( isfunction( Func ), 'BTK:Boot: bad argument #1, function expected, got ' .. type( Func ) )

    self:Print( string.format( 'Executing benchmark test on function at %s!\n', tostring( Func ) ) )

    -- Run hooking.
    hook.Run( 'BTK-Start', Func, ... )

    -- Run this just before we actually start our loop to minimize garbage noise.
    collectgarbage( )

    -- Save before data.
    local Before = self:Data( )

    -- Configuration variables.
    local Config = {
        Count = self.Console.Count:GetInt( ),
        Decimal = self.Console.Decimal:GetInt( )
    }
    
    -- Make sure we aren't dividing by zero.
    if Config.Count == 0 then 
        -- 10000 is a good default variable that gives precision while not stalling the game too long.
    	Config.Count = 10000

        self:Print('Warning! Count was set to 0. Defaulting to 10000 iterations to prevent fatal errors.')
    end

    -- Main loop.
    for i = 1, Config.Count do
        local Success, Error = pcall( Func, ... )

        if not Success then 
            self:Print( string.format( 'Fatal error occurred within %s -> "%s"!', tostring( Func ), Error ) )

            self:Print( string.format( 'Halting benchmark due to error at %s/%s iterations.', i, Config.Count ) )

            return
        end
    end

	-- Save after data.
	local After = self:Data( )

    -- Calculate data.
    self:Calculate( Before.Time, After.Time, Config, 'Timing' )
    self:Calculate( Before.Garbage, After.Garbage, Config, 'Garbage' )

    self:Print( 'Benchmark test complete!' )

    -- Generate "summary".
    local Summary = {
        Before = Before,
        After = After
    }

    self.Summary = Summary

    -- Run post-hooking.
    hook.Run( 'BTK-End', Summary, Func, ... )

    -- Return total "summary" table for ease of use.
    return Summary
end

-- =============================================================================
-- Initialize utility functions.
-- =============================================================================

-- =============================================================================
-- Function to grab the last benchmark ran.
-- @return table: Table containing a before and after index with the statistics.
-- =============================================================================
function BTK:Last( )
    -- This will be nil if there hasn't been a benchmark yet.
    return self.Summary
end

-- =============================================================================
-- Function to showcase how BTK functions.
-- =============================================================================
function BTK:Demo( )
    local function Sample( )
        local x = 0

        for i = 1, 1000 do
            x = x + i
        end
    end

    self:Boot( Sample )
end

-- =============================================================================
-- Internal function to handle creating commands.
-- @param Name (string): The name of the command.
-- @param Callback (function): The callback to run when the command is ran.
-- =============================================================================
function BTK:Command( Name, Callback )
    local Suffix = CLIENT and '_cl' or ''

    concommand.Add( 'btk_' .. Name .. Suffix, function( _, __, ___, Argument )
        Callback( Argument )
    end )
end

-- =============================================================================
-- Initialize console commands.
-- =============================================================================

local Commands = {
    [ 'openscript' ] = function( Argument )
        return BTK:Boot( CompileFile( Argument ) )
    end,

    [ 'run' ] = function( Argument )
        return BTK:Boot( CompileString( Argument ) )
    end,

    [ 'exec' ] = function( Argument )
        return BTK:Boot( _G[ Argument ] )
    end,

    [ 'copy' ] = function( Argument )
        if not BTK.Summary then 
            BTK:Print( 'You haven\'t run any benchmarks yet!' )
            return
        end
    
        local Data = util.TableToJSON( BTK.Summary )

        SetClipboardText( Data )

        BTK:Print( string.format( 'Copied %s of data to clipboard!', string.NiceSize( #Data ) ) )
    end,

    [ 'demo' ] = function( )
        BTK:Print( 'Executing showcase code!' )

        BTK:Demo( )
    end,
}

-- Command launch loop.
for k,v in pairs( Commands ) do
    BTK:Command( k, v )
end

return BTK