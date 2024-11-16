const core = require('@actions/core');
const exec = require('@actions/exec');
const which = require('which');
const os = require('os');

async function run() {
    try {
        // Check if pwsh is available
        let pwshPath = which.sync('pwsh', { nothrow: true });
        if (!pwshPath) {
            // Check if the OS is Ubuntu
            if (os.platform() === 'linux' && os.release().toLowerCase().includes('ubuntu')) {
                await exec.exec('sudo apt-get update && sudo apt-get install -y powershell');
                pwshPath = which.sync('pwsh', { nothrow: true });
                if (!pwshPath) {
                    throw new Error('PowerShell (pwsh) installation failed.');
                }
            }
            else if (os.platform() === 'darwin') {
                await exec.exec('brew install --cask powershell');
                pwshPath = which.sync('pwsh', { nothrow: true });
                if (!pwshPath) {
                    throw new Error('PowerShell (pwsh) installation failed.');
                }
            }
            else if (os.platform() === 'win32') {
                // if choco is found in PATH, install pwsh using choco
                let chocoPath = which.sync('choco', { nothrow: true });
                if (chocoPath) {
                    await exec.exec('choco install powershell -y');
                }
                else {
                    // if choco is not found, download and install pwsh
                    let wingetPath = which.sync('winget', { nothrow: true });
                    if (wingetPath) {
                        await exec.exec('winget install --id Microsoft.PowerShell.Preview --source winget');
                    }
                }
            }
            else
            {
                throw new Error('PowerShell (pwsh) not found.');
            }
        }

        const pwshFolder = __dirname.replace(/[/\\]_init$/, '');
        const pwshScript = `${pwshFolder}/action.ps1`;
        await exec.exec('pwsh', ['-f', pwshScript]);
    } catch (error) {
        core.setFailed(error.message);
    }
}

run();