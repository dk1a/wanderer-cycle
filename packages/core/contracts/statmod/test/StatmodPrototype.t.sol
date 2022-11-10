// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { getAddressById } from "solecs/utils.sol";

import { Test } from "../../Test.sol";

import {
  StatmodPrototype,
  StatmodPrototypeComponent,
  ID as StatmodPrototypeComponentID
} from "../StatmodPrototypeComponent.sol";
import {
  StatmodPrototypeExt,
  StatmodPrototypeExtComponent,
  ID as StatmodPrototypeExtComponentID
} from "../StatmodPrototypeExtComponent.sol";

contract StatmodPrototypeTest is Test {
  StatmodPrototypeComponent protoComp;
  StatmodPrototypeExtComponent protoExtComp;

  // some statmod prototype entities and their topics
  bytes4 lifeTopic = bytes4(keccak256('life'));
  uint256 addLifePE = uint256(keccak256('+# life'));

  function setUp() public override {
    super.setUp();

    // init proto components for names testing
    protoComp = StatmodPrototypeComponent(
      getAddressById(world.components(), StatmodPrototypeComponentID)
    );
    protoExtComp = StatmodPrototypeExtComponent(
      getAddressById(world.components(), StatmodPrototypeExtComponentID)
    );
  }

  function testHashedTopic() public {
    assertEq(
      protoComp.getValue(addLifePE).topic,
      bytes4(keccak256(bytes(protoExtComp.getValue(addLifePE).topic))),
      protoExtComp.getValue(addLifePE).topic
    );
  }

  function testName() public {
    assertEq(
      protoExtComp.getValue(addLifePE).name,
      '+# life'
    );
  }

  function testTopic() public {
    assertEq(
      protoExtComp.getValue(addLifePE).topic,
      'life'
    );
  }

  function testNameSplitForValue() public {
    assertEq(
      protoExtComp.getValue(addLifePE).nameSplitForValue[0],
      '+'
    );
    assertEq(
      protoExtComp.getValue(addLifePE).nameSplitForValue[1],
      ' life'
    );
  }
}