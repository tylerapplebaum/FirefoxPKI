#Tyler Applebaum 6/27/2014
#Logon script to utilize Mozilla's certutil.exe and internal PKI certificates
#Variables
$script:RootCA = "Name of your Root CA"
$script:IssuingCA = "Name of your Issuing CA"
$script:RootCert = "rootpki.cer" #Change this to your root cert name
$script:IssuingCert = "InterPKI.cer" #Change this to your intermediate cert name
$script:temp = "C:\Users\$env:username\Appdata\Local\Temp"
$script:profilepath = "$env:appdata\Mozilla\Firefox\Profiles"
$script:profiles = @(gci $profilepath -attrib D)
$script:scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$script:Trust = "CT,c,C"

function script:Installed {
	If (Test-Path "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"){
	$script:Inst = $True
	}
	Elseif (Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe"){
	$script:Inst = $True
	}
	Else {
	$script:Inst = $False
	}
} #end Installed
function script:AddCert {
	If ($Inst){
	new-item $temp\FirefoxTools -itemtype directory | Out-null
	cp $scriptDir\*.dll, $scriptDir\*.exe, $scriptDir\*.cer $temp\FirefoxTools
		foreach ($profile in $profiles){
			cp $profilepath\$profile\cert8.db $profilepath\$profile\cert8.db.old #back up existing cert db
			& "$temp\FirefoxTools\certutil.exe" -A -n $RootCA -i $temp\FirefoxTools\$RootCert -t $Trust -d $profilepath\$profile
			& "$temp\FirefoxTools\certutil.exe" -A -n $IssuingCA -i $temp\FirefoxTools\$IssuingCert -t $Trust -d $profilepath\$profile
		} #end foreach
	del $temp\FirefoxTools
	} #endif
} #end AddCert
Installed #Run function
AddCert #Run function