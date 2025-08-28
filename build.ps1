param([string]$SdkPath)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$sdk = $null

if ($SdkPath) { $sdk = $SdkPath }
elseif ($env:STARSECTOR_DIR) { $sdk = $env:STARSECTOR_DIR }
else {
  $pf86 = ${env:ProgramFiles(x86)}
  $pf = $env:ProgramFiles
  $candidates = @(
    (Join-Path $pf86 'Fractal Softworks\Starsector'),
    (Join-Path $pf 'Fractal Softworks\Starsector')
  )
  foreach ($c in $candidates) { if (Test-Path (Join-Path $c 'starsector-core\starfarer.api.jar')) { $sdk = $c; break } }
}

if (-not $sdk) { Write-Error 'Could not locate Starsector install. Pass -SdkPath or set STARSECTOR_DIR.' }
$api = Join-Path $sdk 'starsector-core\starfarer.api.jar'
$obf = Join-Path $sdk 'starsector-core\starfarer_obf.jar'
$janino = Join-Path $sdk 'starsector-core\janino.jar'
$commons = Join-Path $sdk 'starsector-core\commons-compiler.jar'
$json = Join-Path $sdk 'starsector-core\json.jar'

if (!(Test-Path $api)) { Write-Error "Could not find starfarer.api.jar at $api" }

$src = 'src'
$out = 'out'
$jarDir = 'jars'
$jar = Join-Path $jarDir 'CommandSaturationProtocol.jar'

New-Item -ItemType Directory -Force $out | Out-Null
New-Item -ItemType Directory -Force $jarDir | Out-Null

$classpath = @($api, $obf, $janino, $commons, $json) -join ';'

try { javac -version | Out-Null } catch { Write-Error 'javac not found on PATH. Install JDK 8+ and retry.' }

$sources = Get-ChildItem -Recurse $src -Filter *.java | % FullName
if (-not $sources) { Write-Error 'No Java sources found under src\' }

& javac --release 8 -cp $classpath -d $out $sources
if ($LASTEXITCODE -ne 0) { throw 'javac failed' }

Push-Location $out
$jarExe = (Get-Command jar -ErrorAction SilentlyContinue)
if (-not $jarExe) { $jarExe = Join-Path $env:JAVA_HOME 'bin\jar.exe' }
if (-not (Test-Path $jarExe)) { Write-Error 'jar tool not found (ensure JDK installed and on PATH)' }
& $jarExe cfm "$root\$jar" "$root\MANIFEST.MF" *
Pop-Location

Write-Host "Built $jar"

