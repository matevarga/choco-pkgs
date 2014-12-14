# import-module C:\Chocolatey\chocolateyInstall\helpers\chocolateyInstaller

function get-binRoot() {
  if($env:chocolatey_bin_root -ne $null) {
    $binRoot = $env:chocolatey_bin_root
  }
  else {
    $binRoot = 'bin'
  }
  
  return Join-Path $env:systemdrive $binRoot
}

$binRoot = get-binRoot
$clojure_version = '1.6.0'
$jline_version = '1.0'
$clojure_home = Join-Path $binRoot "clojure-$clojure_version"

try {
	# installing clojure
	$name = "clojure-$clojure_version"
	$url = "http://repo1.maven.org/maven2/org/clojure/clojure/$clojure_version/clojure-$clojure_version.zip"
	Write-Host $url
	Install-ChocolateyZipPackage $name $url $binRoot
	# Install-ChocolateyZipPackage $name "http://github.com/downloads/clojure/clojure/$name.zip" $binRoot

	# installing jline
	# http://jline.sourceforge.net/
	$jline_name = "jline-$jline_version"
	Install-ChocolateyZipPackage $jline_name "http://ufpr.dl.sourceforge.net/project/jline/jline/$jline_version/$jline_name.zip" $env:TEMP
	Move-Item (Join-Path $env:TEMP "$jline_name\$jline_name.jar") $clojure_home -force

	# clj.bat
	$clj_bat = Join-Path $clojure_home 'clj.bat'

"@echo off
REM :: Usage:
REM ::
REM :: clj                           # Starts REPL
REM :: clj my_script.clj             # Runs the script
REM :: clj my_script.clj arg1 arg2   # Runs the script with arguments

set CLOJURE_DIR=$clojure_home
set CLOJURE_JAR=%CLOJURE_DIR%\$name.jar
set JLINE_JAR=%CLOJURE_DIR%\$jline_name.jar

if (%1) == () (
  java -cp .;%JLINE_JAR%;%CLOJURE_JAR% jline.ConsoleRunner clojure.main
) else (
  java -cp .;%CLOJURE_JAR% clojure.main %1 -- %*
)" | Out-File $clj_bat -encoding ASCII


	# ..\chocolatey\bin\clj.bat
	$clj_link = Join-Path $env:CHOCOLATEYINSTALL 'bin\clj.bat' 
"@echo off
$clj_bat %*" | Out-File $clj_link -encoding ASCII
    
	Write-ChocolateySuccess 'Clojure'
	Write-Host "usage: in prompt, type clj"
} catch {
  Write-ChocolateyFailure 'Clojure' "$($_.Exception.Message)"
  throw 
}