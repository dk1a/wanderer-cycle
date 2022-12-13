// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { Assertions } from "@dk1a/solidity-stringutils/src/test/Assertions.sol";

import { Test } from "../../Test.sol";

import { Topics } from "../../charstat/Topics.sol";
import {
  Op, Element,
  StatmodPrototype,
  StatmodPrototypeComponent,
  ID as StatmodPrototypeComponentID
} from "../StatmodPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../../common/NameComponent.sol";
import { ReverseHashNameComponent, ID as ReverseHashNameComponentID } from "../../common/ReverseHashNameComponent.sol";

contract StatmodPrototypeTest is Test, Assertions {
  StatmodPrototypeComponent protoComp;
  NameComponent nameComp;
  ReverseHashNameComponent rhNameComp;

  // some statmod prototype entities and their topics
  uint256 lifeTopic = Topics.LIFE.toEntity();
  uint256 addLifePE = Topics.LIFE.toStatmodEntity(Op.ADD, Element.ALL);

  function setUp() public override {
    super.setUp();

    // init proto components for names testing
    protoComp = StatmodPrototypeComponent(
      getAddressById(world.components(), StatmodPrototypeComponentID)
    );
    nameComp = NameComponent(
      getAddressById(world.components(), NameComponentID)
    );
    rhNameComp = ReverseHashNameComponent(
      getAddressById(world.components(), ReverseHashNameComponentID)
    );
  }

  function testName() public {
    string memory topicName = rhNameComp.getValue(lifeTopic);
    string memory name = nameComp.getValue(addLifePE);
    assertContains(
      name,
      topicName
    );
  }
}