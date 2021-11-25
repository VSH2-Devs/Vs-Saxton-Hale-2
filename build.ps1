param(
        [Parameter(
                    Mandatory=$true,
                    Position=0,
                    HelpMessage='Set compiler path variable')]
        [string] $spCompPath,

        [Parameter(
                    Mandatory=$true,
                    Position=1,
                    ValueFromRemainingArguments,
                    HelpMessage='Set source and include arguments passed to the compiler')]
        [string[]] $spArgs
)

# location gets pushed on a stack since -Dpath does not work on windows.
Push-Location $PSScriptRoot

$executable = $spCompPath
$outPath = Join-Path -Path $PSScriptRoot -ChildPath '/addons/sourcemod/plugins'
$includePaths = $spArgs.Where{$_ -like '-i=*'}
$scripts = $spArgs.Where{$_ -notlike '-i=*'}
$optimization = '-O2'
$verbosity = '-v2'

foreach ($script in $scripts)
{
        $outArg = [System.IO.Path]::GetFileNameWithoutExtension($script) + ".smx"
        $outArg = Join-Path -Path $outPath -ChildPath $outArg
        $outArg = '-o=' + $outArg

        Write-Host start compiling "'$script'"
        & $executable $script $outArg $includePaths $optimization $verbosity
}

Pop-Location
