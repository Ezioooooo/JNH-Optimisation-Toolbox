$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (-not [Environment]::Is64BitOperatingSystem) {
	throw 'JNH Optimisation requires 64-bit Windows.'
}

$downloadUrl = 'https://github.com/Ezioooooo/JNH-Optimisation-Toolbox/releases/latest/download/JNHOptimisation-Setup-1.0.2.exe'
$expectedSha256 = 'CBDA85982C0EAC31F2256A55F553CCFC176E831A8DFC7F818A4D086913440426'
$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('JNHOptimisation-' + [guid]::NewGuid().ToString('N'))
$installerPath = Join-Path $tempDirectory 'JNHOptimisation-Setup-1.0.2.exe'

New-Item -ItemType Directory -Path $tempDirectory | Out-Null
try {
	Write-Host 'Downloading JNH Optimisation...'
	Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing

	$actualSha256 = (Get-FileHash -LiteralPath $installerPath -Algorithm SHA256).Hash
	if ($actualSha256 -ne $expectedSha256) {
		throw 'SHA-256 verification failed. The downloaded installer does not match the expected file.'
	}

	Write-Host 'Verification passed. Windows will ask for permission to install.'
	$process = Start-Process -FilePath $installerPath -Verb RunAs -Wait -PassThru
	if ($process.ExitCode -ne 0) {
		throw "The installer exited with code $($process.ExitCode)."
	}

	Write-Host 'Installation complete.'
}
finally {
	Remove-Item -LiteralPath $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue
}
