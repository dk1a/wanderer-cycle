// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Assertions } from "@dk1a/solidity-stringutils/src/test/Assertions.sol";

import { BaseTest } from "../../BaseTest.sol";

import { Topics } from "../../charstat/Topics.sol";
import { Op, Element } from "../StatmodPrototypeComponent.sol";

contract StatmodPrototypeTest is BaseTest, Assertions {
  // some statmod prototype entities and their topics
  uint256 lifeTopic = Topics.LIFE.toEntity();
  uint256 addLifePE = Topics.LIFE.toStatmodEntity(Op.ADD, Element.ALL);

  function setUp() public override {
    super.setUp();
  }

  function testName() public {
    string memory topicName = reverseHashNameComponent.getValue(lifeTopic);
    string memory name = nameComponent.getValue(addLifePE);
    assertContains(name, topicName);
  }
}