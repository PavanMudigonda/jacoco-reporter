param(
    [switch]$UpgradePackages
)

if ($UpgradePackages) {
    & npm upgrade "@actions/core"
    & npm upgrade "@actions/exec"
}

# Ensure node_modules are present so ncc bundles @actions/* inline
# instead of deferring them via eval("require"), which breaks on runners.
& npm install

ncc build .\invoke-pwsh.js -o _init
