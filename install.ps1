$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (-not [Environment]::Is64BitOperatingSystem) {
	throw 'JNH Optimisation nécessite Windows 64 bits.'
}

$downloadUrl = 'https://github.com/Ezioooooo/JNH-Optimisation-Toolbox/releases/latest/download/JNHOptimisation-Setup-1.0.1.exe'
$expectedSha256 = '037461FE0EEC02284DE9D47D4BFC9A3026F81315FF78EF2D209B91A0AF54ABF6'
$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('JNHOptimisation-' + [guid]::NewGuid().ToString('N'))
$installerPath = Join-Path $tempDirectory 'JNHOptimisation-Setup-1.0.1.exe'

New-Item -ItemType Directory -Path $tempDirectory | Out-Null
try {
	Write-Host 'Téléchargement de JNH Optimisation...'
	Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing

	$actualSha256 = (Get-FileHash -LiteralPath $installerPath -Algorithm SHA256).Hash
	if ($actualSha256 -ne $expectedSha256) {
		throw 'La vérification SHA-256 a échoué. L’installateur téléchargé ne correspond pas au fichier attendu.'
	}

	Write-Host 'Vérification réussie. Windows va demander l’autorisation d’installation.'
	$process = Start-Process -FilePath $installerPath -Verb RunAs -Wait -PassThru
	if ($process.ExitCode -ne 0) {
		throw "L’installateur s’est terminé avec le code $($process.ExitCode)."
	}

	Write-Host 'Installation terminée.'
}
finally {
	Remove-Item -LiteralPath $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue
}
