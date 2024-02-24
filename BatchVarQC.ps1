function Get-BatchVariables {
    param (
        [string]$batchFilePath
    )

    function Extract-Variable {
        param (
            [string]$line,
            [int]$lineNumber
        )

        # Check if the line contains the "set" keyword...
        if ($line -match '^set\s+(\S+)\s*=\s*(.*)$') {
            # Extract Variable Name...
            $variableName = $Matches[1]
            # Extract Variable Value...
            $variableValue = $Matches[2]
            # Create object for line, name, value, and line number...
            return [PSCustomObject]@{
                LineNumber = $lineNumber
                Line = $line
                Name = $variableName
                Value = $variableValue
            }
        }
    }

    # Read the content of the batch file...
    $batchContent = Get-Content -Path $batchFilePath

    # Array to store variables...
    $variables = @()

    # Extract each line in the batch file and count...
    for ($i = 0; $i -lt $batchContent.Count; $i++) {
        $variable = Extract-Variable -line $batchContent[$i] -lineNumber ($i + 1)
        if ($variable) {
            $variables += $variable
        }
    }
    # Return Variables to Hashtable for quick access...
    return @{
        Variables = $variables
    }
}

# Set the path\name.bat to check file...
$batchFilePath = Join-Path -Path $PSScriptRoot -ChildPath "Config.bat"

# Call function and get the result...
$result = Get-BatchVariables -batchFilePath $batchFilePath
# Return Values from function...
$variables = $result.Variables

# Check ending double quotes...
$misplacedQuotesVariables = @()

foreach ($variable in $variables) {
    $valueToDisplay = "[$($variable.LineNumber)] $($variable.Line)"
    # Check if the value for quotes...
    if ($variable.Name -like '"*' -or $variable.Value -like '"*' -and $variable.Value -notlike '*"') {
        $misplacedQuotesVariables += $valueToDisplay
    }
}

# Report misplaced quotes...
if ($misplacedQuotesVariables.Count -gt 0) {
    Write-Host "::--------------------------------------------------------------------------::"
    Write-Host "::Missing End Quotes Detected`n"
    $misplacedQuotesVariables | ForEach-Object { Write-Host $_ }
    Write-Host "`nOpen Quotes Must Be Closed...`n"
}

# Check all lines for single leading quote...
$linesWithMissingQuotes = @()

foreach ($variable in $variables) {
    $valueToDisplay = "[$($variable.LineNumber)] $($variable.Line)"
    # Check if the value has quotes...
    if (($variable.Value -like '*"' -and $variable.Value -notlike '"*"') -and $variable.Name -notlike '"*') {
        $linesWithMissingQuotes += $valueToDisplay
    }
}

# Report lines with missing quotes...
if ($linesWithMissingQuotes.Count -gt 0) {
    Write-Host "::--------------------------------------------------------------------------::"
    Write-Host "::Missing Leading Quote Detected`n"
    $linesWithMissingQuotes | ForEach-Object { Write-Host $_ }
    Write-Host "`nIf the last character in a Value is (`")... `nThe Variable 'Name' or 'Value' MUST start with (`")...`n"
}

# Validate all variables and their values...
$unreportedVariables = @()

foreach ($variable in $variables) {
    $valueToDisplay = "[$($variable.LineNumber)] $($variable.Line)"
    # Check if the value is quotes or empty...
    if (($variable.Value -eq '"') -or ($variable.Value -eq '')){
        $unreportedVariables += $valueToDisplay
    }
}

# Report variables without values or (")...
if ($unreportedVariables.Count -gt 0) {
    Write-Host "::--------------------------------------------------------------------------::"
    Write-Host "::Missing Values Detected`n"
    $unreportedVariables | ForEach-Object { Write-Host $_ }
    Write-Host "`nAll Config Variables MUST be assigned a Value...`n"
}

# Check conditions and return info...
if ($misplacedQuotesVariables.Count -gt 0 -or $linesWithMissingQuotes.Count -gt 0 -or $unreportedVariables.Count -gt 0) {
    Write-Host "::--------------------------------------------------------------------------::"
    Write-Host "::Quick Config Check`n"
    Write-Host "Error Info:`n[##] Line number in Config.bat containing Error...`n[RE] set 'Name'='Value'`n"
    Write-Host "Error Detected..."
	timeout /t 500
    Exit
} else {
	Write-Host "::--------------------------------------------------------------------------::"
    Write-Host "::Quick Config Check" 
	Write-Host "No Errors Detected..."
	timeout /t 500
    Exit
}