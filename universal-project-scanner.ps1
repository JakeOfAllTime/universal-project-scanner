```powershell
<#
Universal Project Scanner - PowerShell
Author: (your name)
Purpose: inspect a project folder and produce a timestamped text snapshot.
#>

[CmdletBinding()]
param(
    [switch]$NoColor,
    [switch]$DryRun,
    [string]$OutDir = "."
)

function Write-Color {
    param([string]$Text, [string]$Color = "White")
    if ($NoColor) {
        Write-Host $Text
    } else {
        Write-Host $Text -ForegroundColor $Color
    }
}

# Friendly header
Write-Color "Universal Project Scanner" "Cyan"
Write-Color "A lightweight tool to snapshot a project directory (text output)." "Cyan"
Write-Color "If this script is blocked by PowerShell policy, see the README for options." "Yellow"
Write-Color "----`n" "Cyan"

# Basic info
$folderName = Split-Path -Leaf (Get-Location)
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outputFile = Join-Path -Path $OutDir -ChildPath "$folderName-snapshot-$timestamp.txt"

if ($DryRun) {
    Write-Color "Dry run: no file will be written. (Use -DryRun to test)", "Yellow"
} else {
    Write-Color "Writing snapshot to: $outputFile", "Green"
}

# Detection helpers
$projectType = "Unknown"
$techStack = @()

if (Test-Path "package.json") {
    $projectType = "Node.js/JavaScript"
    $techStack += "Node.js"
    try { $pkg = Get-Content "package.json" -Raw -ErrorAction Stop } catch { $pkg = "" }
    if (Test-Path "pages" -or Test-Path "app" -or $pkg -match "next") {
        $projectType = "Next.js Web App"
        $techStack += "Next.js"
    }
    if ($pkg -match "react") { $techStack += "React" }
    if ($pkg -match "tailwind") { $techStack += "Tailwind CSS" }
    if ($pkg -match "ffmpeg") { $techStack += "Video Processing" }
    if ($pkg -match "supabase") { $techStack += "Supabase Database" }
    if (Test-Path "src") { $techStack += "Frontend" }
    if (Test-Path "public") { $techStack += "Web App" }
}

# Python detection
$pyFiles = Get-ChildItem -Filter "*.py" -File -Recurse -ErrorAction SilentlyContinue
if ($pyFiles) {
    if ($projectType -eq "Unknown") { $projectType = "Python" } else { $projectType = "Hybrid Python + $projectType" }
    $techStack += "Python"
    if (Test-Path "requirements.txt") { $techStack += "pip" }
    if (Test-Path "app.py" -or (Get-ChildItem -Recurse -Include "*flask*" -ErrorAction SilentlyContinue)) { $techStack += "Flask" }
    if (Get-ChildItem -Recurse -Include "*django*" -ErrorAction SilentlyContinue) { $techStack += "Django" }
}

if (Get-ChildItem -Filter "*.csproj" -File -ErrorAction SilentlyContinue) {
    $projectType = "C#/.NET"
    $techStack += "C#",".NET"
}
if (Test-Path "pom.xml") {
    $projectType = "Java/Maven"
    $techStack += "Java","Maven"
}
if (Test-Path "Cargo.toml") {
    $projectType = "Rust"
    $techStack += "Rust","Cargo"
}

# Snapshot content builder
$header = "================================================================================"
$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$lines = @()
$lines += $header
$lines += "PROJECT SNAPSHOT: $folderName"
$lines += "Generated: $now"
$lines += "Location: $(Get-Location)"
$lines += $header
$lines += ""
$lines += "=== PROJECT OVERVIEW ==="
$lines += "Project Type: $projectType"
$lines += "Tech Stack: $($techStack -join ', ')"
$lines += "Folder: $folderName"
$lines += ""
$lines += "=== DIRECTORY STRUCTURE ==="
$lines += ""

# top-level listing (name, length, lastwrite)
$top = Get-ChildItem -Force | Sort-Object -Property @{Expression = { -not $_.PSIsContainer }}, Name
$lines += ($top | Format-Table Name, Length, LastWriteTime -AutoSize | Out-String)

# small stats
$totalFiles = (Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
$codeFiles = (Get-ChildItem -Recurse -File -Include *.py,*.js,*.ts,*.tsx,*.cs,*.java -ErrorAction SilentlyContinue | Measure-Object).Count
$projSize = (Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum

$lines += ""
$lines += "=== PROJECT ANALYSIS ==="
$lines += "Total Files: $totalFiles"
$lines += "Code Files: $codeFiles"
$lines += "Project Size (bytes): $projSize"
$lines += ""
$lines += "DETECTED FEATURES:"
if (Test-Path "node_modules") { $lines += "- Node.js dependencies installed" }
if (Test-Path ".venv" -or Test-Path "venv") { $lines += "- Python virtual environment" }
if (Test-Path ".git") { $lines += "- Git version control" }
if (Test-Path "Dockerfile") { $lines += "- Docker containerization (Dockerfile present)" }
if (Test-Path ".github") { $lines += "- GitHub Actions/workflows present" }
if (Test-Path "tests" -or Test-Path "test") { $lines += "- Test suite present" }

$lines += ""
$lines += "=== NEXT STEPS FOR ANALYSIS ==="
$lines += "This snapshot captures the current state of the $folderName project."
$lines += "Use this document to understand project structure, dependencies, and codebase."
$lines += $header
$lines += "END OF SNAPSHOT"
$lines += ""

if ($DryRun) {
    Write-Color "=== DRY RUN OUTPUT START ===" "Yellow"
    $lines | ForEach-Object { Write-Host $_ }
    Write-Color "=== DRY RUN OUTPUT END ===" "Yellow"
} else {
    try {
        $lines | Out-File -FilePath $outputFile -Encoding utf8
        Write-Color "Snapshot written: $outputFile" "Green"
    } catch {
        Write-Color "Error writing snapshot: $_" "Red"
    }
}

Write-Color "Done." "Cyan"
