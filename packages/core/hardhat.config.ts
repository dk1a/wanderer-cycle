import '@nomicfoundation/hardhat-chai-matchers';
import '@nomiclabs/hardhat-ethers'
import '@typechain/hardhat'
import 'hardhat-preprocessor'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { readFileSync } from 'fs'

function getRemappings() {
  return readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean) // remove empty lines
    .map((line) => line.trim().split("="));
}

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
export default {
  solidity: {
    compilers: [
      {
        version: '0.8.16',
      },
    ],
  },
  preprocess: {
    eachLine: (hre: HardhatRuntimeEnvironment) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import .*"\s*;/i)) {
          for (const [from, to] of getRemappings()) {
            const regex = new RegExp(`^(\s*import .*")(${from})(.*"\s*;)`);
            if (line.match(regex)) {
              console.log(line)
              line = line.replace(regex, `$1${to}$3`);
              console.log(line)
              break;
            }
          }
        }
        return line;
      },
    }),
  },
  paths: {
    cache: "./cache_hardhat",
  },
}