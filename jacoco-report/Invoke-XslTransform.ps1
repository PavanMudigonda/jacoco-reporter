
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$xmlFile,

    [Parameter(Mandatory)]
    [string]$xslFile,

    [string]$mdFile    = $null,
    [hashtable]$xslParams = $null
)

## ── Resolve relative paths ────────────────────────────────────────────────────

if ($xmlFile -notmatch '^[/\\]') {
    $xmlFile = [System.IO.Path]::Combine($PWD, $xmlFile)
    Write-Verbose "Resolved XML : $xmlFile"
}

if ($xslFile -notmatch '^[/\\]') {
    $xslFile = [System.IO.Path]::Combine($PWD, $xslFile)
    Write-Verbose "Resolved XSL : $xslFile"
}

if (-not $mdFile) {
    $mdFile = ($xmlFile -ireplace '\.xml$', '') + '.md'
    Write-Verbose "Resolved MD  : $mdFile (default)"
} elseif ($mdFile -notmatch '^[/\\]') {
    $mdFile = [System.IO.Path]::Combine($PWD, $mdFile)
    Write-Verbose "Resolved MD  : $mdFile"
}

## ── Load XSLT stylesheet ──────────────────────────────────────────────────────

$urlResolver = [System.Xml.XmlUrlResolver]::new()
$xsltSettings = [System.Xml.Xsl.XsltSettings]::new()
$xslt = [System.Xml.Xsl.XslCompiledTransform]::new()

try {
    $xslt.Load($xslFile, $xsltSettings, $urlResolver)
    Write-Verbose "Loaded XSL stylesheet: $xslFile"
} catch {
    Write-Error "Failed to load XSL stylesheet '$xslFile': $_"
    return
}

## ── Build XSLT argument list ──────────────────────────────────────────────────

$argList = [System.Xml.Xsl.XsltArgumentList]::new()
if ($xslParams) {
    foreach ($kv in $xslParams.GetEnumerator()) {
        $argList.AddParam($kv.Key, [string]::Empty, $kv.Value)
    }
}

## ── Transform XML → Markdown ──────────────────────────────────────────────────

$readerSettings = [System.Xml.XmlReaderSettings]::new()
$readerSettings.DtdProcessing = [System.Xml.DtdProcessing]::Parse

$writer = [System.IO.StreamWriter]::new($mdFile)
try {
    Write-Verbose "Transforming: $xmlFile → $mdFile"
    $reader = [System.Xml.XmlReader]::Create($xmlFile, $readerSettings)
    try {
        $xslt.Transform(
            [System.Xml.XmlReader]$reader,
            [System.Xml.Xsl.XsltArgumentList]$argList,
            [System.IO.TextWriter]$writer
        )
    } finally {
        $reader.Dispose()
    }
} finally {
    $writer.Dispose()
}

Write-Verbose "Transform complete → $mdFile"
