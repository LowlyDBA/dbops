class DBOpsLog : DbUp.Engine.Output.IUpgradeLog {
    #Hidden properties
    hidden [string]$LogToFile
    hidden [bool]$Silent
    hidden [object]$CallStack
    
    #Constructors
    DBOpsLog ([bool]$silent, [string]$outFile, [bool]$append) {
        $this.silent = $silent
        $this.logToFile = $outFile
        $txt = "Logging started at " + (get-date).ToString()
        if ($outFile) {
            if ($append) {
                $txt | Out-File $this.logToFile -Append
            }
            else {
                $txt | Out-File $this.logToFile -Force
            }
        }
        $this.CallStack = (Get-PSCallStack)[1]
    }
    
    #Methods
    [void] WriteInformation([string]$format, [object[]]$params) {
        $level = switch ($this.silent) {
            $true { 'Debug' }
            default { 'Host '}
        }
        $splatParam = @{
            Tag          = 'Deployment', 'dbup'
            FunctionName = $this.callStack.Command
            ModuleName   = $this.callstack.InvocationInfo.MyCommand.ModuleName
            File         = $this.callStack.Position.File
            Line         = $this.callStack.Position.StartLineNumber
            Level        = $level
            Message      = $format -f $params
            
        }
        Write-PSFMessage @splatParam
        if ($this.logToFile) {
            $this.WriteToFile($format, $params)
        }
    }
    [void] WriteError([string]$format, [object[]]$params) {
        $level = switch ($this.silent) {
            $true { 'Debug' }
            default { 'Critical '}
        }
        $splatParam = @{
            Tag          = 'Deployment', 'dbup'
            FunctionName = $this.callStack.Command
            ModuleName   = $this.callstack.InvocationInfo.MyCommand.ModuleName
            File         = $this.callStack.Position.File
            Line         = $this.callStack.Position.StartLineNumber
            Level        = $level
            Message      = $format -f $params
            
        }
        Write-PSFMessage @splatParam
        if ($this.logToFile) {
            $this.WriteToFile($format, $params)
        }
    }
    [void] WriteWarning([string]$format, [object[]]$params) {
        $level = switch ($this.silent) {
            $true { 'Debug' }
            default { 'Warning '}
        }
        $splatParam = @{
            Tag          = 'Deployment', 'dbup'
            FunctionName = $this.callStack.Command
            ModuleName   = $this.callstack.InvocationInfo.MyCommand.ModuleName
            File         = $this.callStack.Position.File
            Line         = $this.callStack.Position.StartLineNumber
            Level        = $level
            Message      = $format -f $params
            
        }
        Write-PSFMessage @splatParam
        if ($this.logToFile) {
            $this.WriteToFile($format, $params)
        }
    }
    [void] WriteToFile([string]$format, [object[]]$params) {
        $format -f $params | Out-File $this.logToFile -Append
    }
}