<#
PowerShell script to copy images from user's Pictures folder into the project's Images/ folder
and update gallery.html between the markers <!-- GALLERY-IMAGES-START --> and <!-- GALLERY-IMAGES-END -->
#>

param(
    [string]$SourceFolder = "$env:USERPROFILE\Pictures",
    [int]$MaxFiles = 12
)

if (-not (Test-Path $SourceFolder)) {
    Write-Error "Source folder not found: $SourceFolder"
    exit 1
}

$destDir = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "..\Images"
$destDir = Resolve-Path $destDir
$destDir = $destDir.Path

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir | Out-Null
}

$exts = @('*.jpg','*.jpeg','*.png','*.gif')
$files = Get-ChildItem -Path $SourceFolder -Include $exts -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First $MaxFiles
if (-not $files -or $files.Count -eq 0) {
    Write-Host "No image files found in $SourceFolder"
    exit 0
}

Get-ChildItem -Path $destDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'photo*' } | Remove-Item -Force

$copied = @()
$index = 1
foreach ($f in $files) {
    $ext = $f.Extension
    $name = "photo{0:D2}{1}" -f $index, $ext
    $dest = Join-Path $destDir $name
    Copy-Item -Path $f.FullName -Destination $dest -Force
    $copied += [System.IO.Path]::GetFileName($dest)
    $index++
}

# Update gallery.html
$galleryPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "..\gallery.html"
$galleryPath = Resolve-Path $galleryPath
$galleryPath = $galleryPath.Path

$content = Get-Content -Path $galleryPath -Raw -ErrorAction Stop
$startMarker = '<!-- GALLERY-IMAGES-START -->'
$endMarker = '<!-- GALLERY-IMAGES-END -->'

$startIdx = $content.IndexOf($startMarker)
$endIdx = $content.IndexOf($endMarker)

if ($startIdx -lt 0 -or $endIdx -lt 0) {
    Write-Error "Gallery markers not found in gallery.html. Make sure the file contains $startMarker and $endMarker."
    exit 1
}

$before = $content.Substring(0, $startIdx + $startMarker.Length)
$after = $content.Substring($endIdx)

# Build new image tags
$imageLines = $copied | ForEach-Object { ('          <img src="Images/{0}" alt="User photo" />' -f $_) }
$newBlock = "`n" + ($imageLines -join "`n") + "`n          "

$newContent = $before + $newBlock + $after

Set-Content -Path $galleryPath -Value $newContent -Force

Write-Host "Imported $($copied.Count) images to $destDir and updated gallery.html"
Write-Host "Files:"
$copied | ForEach-Object { Write-Host " - $_" }

Write-Host "Open gallery.html to preview the imported images."