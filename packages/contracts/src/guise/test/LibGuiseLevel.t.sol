// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import "forge-std/console.sol";

import { LibExperience } from "../../charstat/LibExperience.sol";
import { LibGuiseLevel } from "../LibGuiseLevel.sol";

import { ActiveGuiseComponent, ID as ActiveGuiseComponentID } from "../ActiveGuiseComponent.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "../GuisePrototypeComponent.sol";

import { getGuiseProtoEntity } from "../GuisePrototypeComponent.sol";
import { getSkillProtoEntity } from "../../skill/SkillPrototypeComponent.sol";

contract LibGuiseLevelTest is BaseTest {
  using LibExperience for LibExperience.Self;

  // entities
  uint256 userEntity = uint256(keccak256("userEntity"));
  uint256 otherEntity = uint256(keccak256("otherEntity"));

  // guise
  uint256 guiseEntity = getGuiseProtoEntity("Warrior");

  ActiveGuiseComponent activeGuiseComp = ActiveGuiseComponent(getAddressById(components, ActiveGuiseComponentID));
  GuisePrototypeComponent guiseProto = GuisePrototypeComponent(getAddressById(components, GuisePrototypeComponentID));

  function setUp() public virtual override {
    super.setUp();

    uint256 guiseProtoEntity = activeGuiseComp.getValue(guiseProtoEntity);
    uint32 levelMul = guiseProto.getValue(guiseProtoEntity).levelMul;
  }

  function test_guise() public {}

  function testSetup() public {}
}
