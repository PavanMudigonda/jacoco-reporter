
const core = require('@actions/core');
const exec = require('@actions/exec');
const os   = require('os');

// Attempt to install PowerShell on runners where it isn't pre-installed (#55).
async function installPwsh() {
    const platform = os.platform();
    core.info(`PowerShell not found. Attempting auto-install on platform: ${platform}`);

    if (platform === 'linux') {
        // Try snap first (available on most modern Ubuntu runners).
        try {
            await exec.exec('sudo', ['snap', 'install', 'powershell', '--classic']);
            core.info('PowerShell installed via snap.');
            return;
        } catch {
            core.info('snap unavailable, falling back to apt-get...');
        }
        // Fall back to the Microsoft apt repository.
        await exec.exec('sudo', ['apt-get', 'update', '-y']);
        await exec.exec('sudo', ['apt-get', 'install', '-y', 'powershell']);
        core.info('PowerShell installed via apt-get.');

    } else if (platform === 'darwin') {
        await exec.exec('brew', ['install', '--cask', 'powershell']);
        core.info('PowerShell installed via Homebrew.');

    } else {
        throw new Error(
            'Cannot auto-install PowerShell on this platform. ' +
            'Please install pwsh manually: ' +
            'https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell'
        );
    }
}

async function run() {
    try {
        // Pre-flight: verify pwsh is available; install it if not (#55).
        let pwshAvailable = false;
        try {
            await exec.exec('pwsh', ['--version'], { silent: true, ignoreReturnCode: false });
            pwshAvailable = true;
        } catch {
            // pwsh not on PATH or not installed
        }

        if (!pwshAvailable) {
            await installPwsh();
        }

        const pwshFolder = __dirname.replace(/[/\\]_init$/, '');
        const pwshScript = `${pwshFolder}/action.ps1`;
        await exec.exec('pwsh', ['-f', pwshScript]);

    } catch (error) {
        core.setFailed(error.message);
    }
}

run();
