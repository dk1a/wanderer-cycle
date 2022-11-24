// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Test } from "../../Test.sol";

import { getAddressById } from "solecs/utils.sol";

import { LibCharstat } from "../../charstat/LibCharstat.sol";
import {
  CombatSystem,
  ID as CombatSystemID,
  Action
} from "../CombatSystem.sol";

contract CombatSystemTest is Test {
  using LibCharstat for LibCharstat.Self;

  address writer = address(bytes20(keccak256('writer')));

  uint256 playerEntity = uint256(keccak256('playerEntity'));
  uint256 encounterEntity = uint256(keccak256('encounterEntity'));

  // libs
  LibCharstat.Self playerCharstat;
  LibCharstat.Self encounterCharstat;

  CombatSystem combatSystem;

  function setUp() public virtual override {
    super.setUp();

    // init libs
    playerCharstat = LibCharstat.__construct(world.components(), playerEntity);
    encounterCharstat = LibCharstat.__construct(world.components(), encounterEntity);

    // get systems
    combatSystem = CombatSystem(getAddressById(world.systems(), CombatSystemID));
    combatSystem.authorizeWriter(writer);

    // give player and encounter some life
    playerCharstat.setFullCurrents();
    encounterCharstat.setFullCurrents();
  }

  function testInitialLife() public {
    assertEq(playerCharstat.getLifeCurrent(), 2);
    assertEq(encounterCharstat.getLifeCurrent(), 2);
  }

  function testExecute() public {
    vm.prank(writer);
    Action[] memory noActions;
    combatSystem.executePVE(playerEntity, encounterEntity, noActions, noActions);
  }

  // TODO more tests
}