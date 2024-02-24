# BatchVar-QC
Checks batch file variables for missing quotes and values.

**Usage:** <br>
*Option 1*: Copy the BatchVarQC.ps1 script to the location of the file to check.

1. Open BatchVarQC.ps1 and change `Config.bat` to the name of the file name and extension.
2. $batchFilePath = Join-Path -Path $PSScriptRoot -ChildPath `"Config.bat"`

<br>

*Option 2*: Run script in different folder.

1a. If running the script from a different location, specify the full file path like follows.<br>
2a. $batchFilePath = `"C:\Users\Administrator\Desktop\Test\Config.bat"`

<br>

3. Run the script in Powershell or Powershell:ISE.
3. *Note:* The script will run for 5 minutes before closing. You can safely stop the script in ISE once it has completed.<br>

<br>

**Valid Variables:**

```
set Test1=1abc
set Test2="1abc"
set "Test3=1abc"
```
<br>

**Error Info:** <br>
[##] Line number in Config.bat containing Error... <br>
[RE] set 'Name'='Value'
```
::--------------------------------------------------------------------------::
::Missing End Quotes Detected

[36] set "Test3=7
[42] set "Test5=
[68] set Test6="D:\steamcmd\steamcmd.exe

Open Quotes Must Be Closed...

::--------------------------------------------------------------------------::
::Missing Leading Quote Detected

[26] set Test1=O:\asamultitest\island"
[34] set Test2=2"

If the last character in a Value is (")... 
The Variable 'Name' or 'Value' MUST start with (")...

::--------------------------------------------------------------------------::
::Missing Values Detected

[38] set "Test4="
[42] set "Test5=
[74] set Test7= 

All Config Variables MUST be assigned a Value...
```
