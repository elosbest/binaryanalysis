Clear-Host

$errorActionPreference = 'SilentlyContinue'
$current_process = Get-Process -Id $PID
$current_process.PriorityClass = "High"
$null = Set-Clipboard -Value $null

$psHistoryPath = "C:\Users\$($env:USERNAME)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

if (Test-Path $psHistoryPath) {
    $content = Get-Content $psHistoryPath
    $lineCount = $content.Count
    if ($lineCount -ge 1) {
        $content = $content[0..($lineCount-2)]
        Set-Content -Path $psHistoryPath -Value $content
    } 
}

# 0
$key = Read-Host "Enter Key" -AsSecureString
$plainKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($key))
if ($plainKey -ne ".begin") {
    Write-Host "Incorrect key."
    Exit
}

Clear-Host

# 1
$file = "C:\binaryCS.txt"

do {
    $input = Read-Host "Input"
    if ($input -ne ".parse") {
        Add-Content $file -Value $input
    }
} until ($input -eq ".parse")
Write-Host ""

# 2
# Unique Paths from File
$paths = Get-Content -Path $file | Select-Object -Unique
# NEW Removing Empty Strings:
$paths = $paths | Where-Object { $_.Trim().Length -gt 0 }

# Removing File
Remove-Item $file

# 3
$notFound = @()
$sigs = @()
$noSigs = @()
$count = 1

# Iterate over each path in the array
$sigsHigh = @()
$keyword = "Cheat Engine"

foreach ($path in $paths) {
    Write-Host "Analyzing Paths: ${count}/$($paths.Count)" -ForegroundColor Yellow -BackgroundColor DarkCyan -NoNewline
    $count++
    Write-Host "`r" -NoNewline
    # Check if the path exists and is a file
    if (Test-Path $path -PathType Leaf) {
        # Check the binary signature of the file
        $sig = Get-AuthenticodeSignature $path -ErrorAction SilentlyContinue

        if ($sig -eq $null -or $sig.Status -ne "Valid") {
            $noSigs += $path
        }
        else {
            $sigs += $path
            # Ce Check
            if ($sig -and $sig.SignerCertificate.Subject -like "*$keyword*") {
                $sigsHigh += $path
            }
        }
    }
    else {
        # Add the path to the $notfound list if it doesn't exist
        $notFound += $path
    }
    [System.Console]::Out.Flush()
}
Write-Host ""

Write-Host "Not Found:" -ForegroundColor Red -BackgroundColor Black
foreach ($path in $notFound) {
    Write-Host $path -ForegroundColor Cyan -BackgroundColor Black
}
Write-Host ""

Write-Host "Signed (High Threats):" -ForegroundColor Red -BackgroundColor Black
foreach ($threat in $sigsHigh) {
    Write-Host $threat -ForegroundColor Cyan -BackgroundColor Black
}
Write-Host ""

<#Write-Host "Not Signed:" -ForegroundColor Red -BackgroundColor Black
foreach ($path in $noSigs) {
    Write-Host $path -ForegroundColor Yellow -BackgroundColor Black
}#>

# String Searching
$stringsHigh = "autoclick","mouse_event","minecraft","minecraft.windows","cheatengine","nitr0", "Ambrosial"
$stringsPot = "clicker","l mouse","lbuttondown","pyautogui",".amogus","OnClickListener()","UwU.class","if(isClicking)",".mousePress","anygrabber","Reeach","\[Bind:","key_key.","killaura.killaura","dreamagent","JnativeHook","vape.gg","\[Bind","LCLICK","RCLICK","self destruct", "TrackMouseEvent", "PINGING", "C:\\Dev\\Client\\x64\\Release\\client.pdb"
# $stringsHighSIGs = "autoclick","mouse_event","minecraft","minecraft.windows","cheatengine","nitr0", "Ambrosial", "TrackMouseEvent", "PINGING", "C:\\Dev\\Client\\x64\\Release\\client.pdb" 


# High Threats (no sig)
$noSigsHigh = @()
$noSigsNotHigh = @()
$count = 1
foreach ($path in $noSigs) {
    Write-Host "Analyzing Unsigned Paths Stage 1: ${count}/$($noSigs.Count)" -ForegroundColor Yellow -BackgroundColor DarkCyan -NoNewline
    $count++
    Write-Host "`r" -NoNewline
    if ((Get-Content $path -ErrorAction SilentlyContinue) -match ($stringsHigh -join "|")) {
        $noSigsHigh += $path
    }
    else {
        $noSigsNotHigh += $path
    }
    [System.Console]::Out.Flush()
}
Write-Host ""

Write-Host "Not Signed (High Threats):" -ForegroundColor Red -BackgroundColor Black
foreach ($threat in $noSigsHigh) {
    Write-Host $threat -ForegroundColor Cyan -BackgroundColor Black
}
Write-Host ""

# Potential Threats (no sig)
$noSigsPot = @()
$noSigsNoFlag = @()
$count = 1
foreach ($path in $noSigsNotHigh) {
    Write-Host "Analyzing Unsigned Paths Stage 2: ${count}/$($noSigsNotHigh.Count)" -ForegroundColor Yellow -BackgroundColor DarkCyan -NoNewline
    $count++
    Write-Host "`r" -NoNewline
    if ((Get-Content $path -ErrorAction SilentlyContinue) -match ($stringsPot -join "|")) {
        $noSigsPot += $path
    }
    else {
        $noSigsNoFlag += $path
    }
    [System.Console]::Out.Flush()
}
Write-Host ""

Write-Host "Not Signed (Potential Threats):" -ForegroundColor Yellow -BackgroundColor Black
foreach ($threat in $noSigsPot) {
    Write-Host $threat -ForegroundColor Cyan -BackgroundColor Black
}
Write-Host ""

Write-Host "Not Signed (No Match):" -ForegroundColor Yellow -BackgroundColor Black
foreach ($threat in $noSigsNoFlag) {
    Write-Host $threat -ForegroundColor Cyan -BackgroundColor Black
}
Write-Host ""

<#
# High (Potential Because Signed) Threats (sig)
$sigsHigh = @()
$count = 1
foreach ($path in $sigs) {
    Write-Host "Analyzing Signed Paths: ${count}/$($sigs.Count)" -ForegroundColor Yellow -BackgroundColor DarkCyan -NoNewline
    $count++;
    Write-Host "`r" -NoNewline
    if ((Get-Content $path -ErrorAction SilentlyContinue) -match ($stringsHighSIGs -join "|")) {
        $sigsHigh += $path
    }
}
Write-Host ""

Write-Host "Signed (Potential Threats):" -ForegroundColor Green -BackgroundColor Black
foreach ($threat in $sigsHigh) {
    Write-Host $threat -ForegroundColor Cyan -BackgroundColor Black
}
#>
$HistoryFile = Join-Path $env:APPDATA "Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
Remove-Item $HistoryFile -ErrorAction SilentlyContinue