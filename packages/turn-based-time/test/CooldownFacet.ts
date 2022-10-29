import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { ethers } from 'hardhat'
import {
  CooldownFacet,
  CooldownFacet__factory,
} from '../typechain-types'

describe('CooldownFacet', function () {
  let holder: SignerWithAddress
  let recipient: SignerWithAddress
  let instance: CooldownFacet

  before(async function () {
    [holder, recipient] = await ethers.getSigners()
  })

  beforeEach(async function () {
    const [deployer] = await ethers.getSigners()
    instance = await new CooldownFacet__factory(deployer).deploy()
  })

  describe('#startCd(uint256,bytes32,(uint64,uint64))', function () {
    /*it('emits TransferSingle event', async function () {
      let id = ethers.constants.Zero;
      let amount = ethers.constants.Two;

      await expect(instance.__mint(holder.address, id, amount))
        .to.emit(instance, 'TransferSingle')
        .withArgs(
          holder.address,
        )
    })*/

    /*describe('reverts if', function () {
      it('mint is made to the zero address', async function () {
        await expect(
          instance.__mint(
            ethers.constants.AddressZero,
          ),
        ).to.be.revertedWithCustomError(
          instance,
          'ERC1155Base__MintToZeroAddress',
        )
      })
    })*/
  })
})