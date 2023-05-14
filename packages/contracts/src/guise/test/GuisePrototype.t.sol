// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";

import "forge-std/console.sol";

import { getGuiseProtoEntity } from "../GuisePrototypeComponent.sol";

contract GuisePrototypeTest is BaseTest {
  // sample guise entity
  uint256 guiseEntity = getGuiseProtoEntity("Warrior");

  function setUp() public virtual override {
    super.setUp();
  }

  function test_sample_effectPrototype_statmodLengths() public {
    assertEq(effectPrototypeComponent.getValue(guiseEntity).statmodProtoEntities.length, 1);
  }
}
