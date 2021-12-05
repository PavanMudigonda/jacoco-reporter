
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$xmlFile,
    [string]$mdFile=$null,
    [string]$xslFile=$null,
    [hashtable]$xslParams=$null
)

if ($xmlFile -notmatch '^[/\\]') {
    $xmlFile = [System.IO.Path]::Combine($PWD, $xmlFile)
    Write-Verbose "Resolving XML file relative to current directory: $xmlFile"
}

if (-not $mdFile) {
    $mdFile = $xmlFile
    if ([System.IO.Path]::GetExtension($xmlFile) -ieq '.xml') {
        $mdFile = $xmlFile -ireplace '.xml$',''
    }
    $mdFile += '.md'
    Write-Verbose "Resolving default MD file: $mdFile"
}
elseif ($mdFile -notmatch '^[/\\]') {
    $mdFile = [System.IO.Path]::Combine($PWD, $mdFile)
    Write-Verbose "Resolving MD file relative to current directory: $mdFile"
}

if (-not $xslFile) {
    $xslFile = "$PSScriptRoot/nunitxml2md.xsl"
    Write-Verbose "Resolving default XSL file: $xslFile"
}
elseif ($xslFile -notmatch '^[/\\]') {
    $xslFile = [System.IO.Path]::Combine($PWD, $xslFile)
    Write-Verbose "Resolving XSL file relative to current directory: $xslFile"

}

class NUnitXML {
    [double]DiffSeconds([datetime]$from, [datetime]$till) {
        return ($till - $from).TotalSeconds
    }
}


if (-not $script:xslt) {
    $script:urlr = [System.Xml.XmlUrlResolver]::new()
    $script:opts = [System.Xml.Xsl.XsltSettings]::new()
    #$script:opts.EnableScript = $true
    $script:xslt = [System.Xml.Xsl.XslCompiledTransform]::new()
    try {
        $script:xslt.Load($xslFile, $script:opts, $script:urlr)
    }
    catch {
        Write-Error $Error[0]
        return
    }
    Write-Verbose "Loaded XSL transformer"
}

$script:list = [System.Xml.Xsl.XsltArgumentList]::new()
$script:list.AddExtensionObject("urn:nuxml", [NUnitXML]::new())
if ($xslParams) {
    foreach ($xp in $xslParams.GetEnumerator()) {
        $script:list.AddParam($xp.Key, [string]::Empty, $xp.Value)
    }
}

$script:wrtr = [System.IO.StreamWriter]::new($mdFile)
try {
    Write-Verbose "Transforming XML to MD"
    $script:xslt.Transform(
        [string]$xmlFile,
        [System.Xml.Xsl.XsltArgumentList]$script:list,
        [System.IO.TextWriter]$script:wrtr)
}
finally {
    $script:wrtr.Dispose()
}
