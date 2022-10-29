import '@nomicfoundation/hardhat-chai-matchers';
import '@nomiclabs/hardhat-ethers'
import '@typechain/hardhat'

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
  }
}