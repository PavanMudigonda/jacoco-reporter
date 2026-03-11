/******/ (() => { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ 781:
/***/ ((module) => {

module.exports = eval("require")("@actions/core");


/***/ }),

/***/ 579:
/***/ ((module) => {

module.exports = eval("require")("@actions/exec");


/***/ }),

/***/ 857:
/***/ ((module) => {

"use strict";
module.exports = require("os");

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __nccwpck_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		var threw = true;
/******/ 		try {
/******/ 			__webpack_modules__[moduleId](module, module.exports, __nccwpck_require__);
/******/ 			threw = false;
/******/ 		} finally {
/******/ 			if(threw) delete __webpack_module_cache__[moduleId];
/******/ 		}
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/compat */
/******/ 	
/******/ 	if (typeof __nccwpck_require__ !== 'undefined') __nccwpck_require__.ab = __dirname + "/";
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};

const core = __nccwpck_require__(781);
const exec = __nccwpck_require__(579);
const os   = __nccwpck_require__(857);

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

module.exports = __webpack_exports__;
/******/ })()
;