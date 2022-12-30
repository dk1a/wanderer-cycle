// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { OwnableWritable } from "@latticexyz/solecs/src/OwnableWritable.sol";

import { Topics } from "../../charstat/Topics.sol";
import { LibCharstat, PStat } from "../../charstat/LibCharstat.sol";
import { Statmod, Op, Element, EL_L } from "../../statmod/Statmod.sol";
import { CombatSubsystem, Action, ActionType } from "../CombatSubsystem.sol";
import { LibActiveCombat } from "../LibActiveCombat.sol";

contract CombatSubsystemTest is BaseTest {
  using LibCharstat for LibCharstat.Self;
  using Statmod for Statmod.Self;

  address writer = address(bytes20(keccak256('writer')));

  uint256 playerEntity = uint256(keccak256('playerEntity'));
  uint256 encounterEntity = uint256(keccak256('encounterEntity'));

  // libs
  LibCharstat.Self playerCharstat;
  LibCharstat.Self encounterCharstat;

  Action[] _noActions;

  // default data
  uint32 constant initLevel = 2;
  uint32 initLife;
  uint32 initAttack;
  uint256 maxRounds = 12;

  // statmod proto entities
  uint256 levelPE = Topics.LEVEL.toStatmodEntity(Op.BADD, Element.ALL);

  function setUp() public virtual override {
    super.setUp();

    // authorize writer
    combatSubsystem.authorizeWriter(writer);

    // init libs
    playerCharstat = LibCharstat.__construct(world.components(), playerEntity);
    encounterCharstat = LibCharstat.__construct(world.components(), encounterEntity);

    // give direct levels
    // (note: don't change statmods directly outside of tests, use effects)
    playerCharstat.statmod.increase(levelPE, initLevel);
    encounterCharstat.statmod.increase(levelPE, initLevel);

    // initialize and fill up life, mana
    playerCharstat.setFullCurrents();
    encounterCharstat.setFullCurrents();

    // activate combat between player and encounter
    combatSubsystem.executeActivateCombat(playerEntity, encounterEntity, maxRounds);

    initLife = playerCharstat.getLifeCurrent();
    initAttack = playerCharstat.getAttack()[uint256(Element.PHYSICAL)];
  }

  // ================ HELPERS ================

  function _sumElements(uint32[EL_L] memory elemValues) internal pure returns (uint32 result) {
    // TODO elemental values could use their own library, or at least some helpers
    for (uint256 i = 1; i < EL_L; i++) {
      result += elemValues[i];
    }
  }

  function _actions1Attack() internal pure returns (Action[] memory result) {
    result = new Action[](1);
    result[0] = Action({
      actionType: ActionType.ATTACK,
      actionEntity: 0
    });
  }

  function _actions2Attacks() internal pure returns (Action[] memory result) {
    result = new Action[](2);
    result[0] = Action({
      actionType: ActionType.ATTACK,
      actionEntity: 0
    });
    result[1] = Action({
      actionType: ActionType.ATTACK,
      actionEntity: 0
    });
  }

  // ================ TESTS ================

  // this just shows the values I expect, and may need to change if LibCharstat config changes
  function test_setUp() public {
    assertEq(initLife, 2 + 2 * initLevel);
    assertEq(playerCharstat.getLifeCurrent(), encounterCharstat.getLifeCurrent());

    assertEq(initAttack, 1 + initLevel / 2);
    assertEq(_sumElements(playerCharstat.getAttack()), initAttack);
    assertEq(_sumElements(playerCharstat.getAttack()), _sumElements(encounterCharstat.getAttack()));
  }

  function test_combatPVERound_notWriter() public {
    vm.prank(address(bytes20(keccak256('notWriter'))));
    vm.expectRevert(OwnableWritable.OwnableWritable__NotWriter.selector);
    combatSubsystem.executePVERound(
      playerEntity, encounterEntity, _noActions, _noActions
    );
  }

  // skipping a round is fine
  function test_combatPVERound_noActions() public {
    vm.prank(writer);
    CombatSubsystem.CombatResult result = combatSubsystem.executePVERound(
      playerEntity, encounterEntity, _noActions, _noActions
    );
    assertEq(uint8(result), uint8(CombatSubsystem.CombatResult.NONE));
  }

  // by default entities can only do 1 action per round
  function test_combatPVERound_invalidActionsLength() public {
    vm.prank(writer);
    vm.expectRevert(CombatSubsystem.CombatSubsystem__InvalidActionsLength.selector);
    combatSubsystem.executePVERound(
      playerEntity, encounterEntity, _actions2Attacks(), _actions2Attacks()
    );
  }

  // an unopposed single attack
  function test_combatPVERound_playerAttacks_1() public {
    vm.prank(writer);

    CombatSubsystem.CombatResult result = combatSubsystem.executePVERound(
      playerEntity, encounterEntity, _actions1Attack(), _noActions
    );
    assertEq(uint8(result), uint8(CombatSubsystem.CombatResult.NONE));
    assertEq(encounterCharstat.getLifeCurrent(), initLife - initAttack);
  }

  // unopposed player attacks, enough to get victory
  function test_combatPVERound_playerAttacks_victory() public {
    vm.prank(writer);

    CombatSubsystem.CombatResult result;
    // do enough attacks to defeat encounter
    uint256 attacksNumber = initLife / initAttack;
    for (uint256 i; i < attacksNumber; i++) {
      result = combatSubsystem.executePVERound(
        playerEntity, encounterEntity, _actions1Attack(), _noActions
      );
      if (i != attacksNumber - 1) {
        assertEq(uint8(result), uint8(CombatSubsystem.CombatResult.NONE));
      }
    }
    assertEq(uint8(result), uint8(CombatSubsystem.CombatResult.VICTORY));
    assertEq(encounterCharstat.getLifeCurrent(), 0);
  }

  // unopposed encounter attacks, enough to get defeat
  function test_combatPVERound_encounterAttacks_defeat() public {
    vm.prank(writer);

    CombatSubsystem.CombatResult result;
    // do enough attacks to defeat player
    uint256 attacksNumber = initLife / initAttack;
    for (uint256 i; i < attacksNumber; i++) {
      result = combatSubsystem.executePVERound(
        playerEntity, encounterEntity, _noActions, _actions1Attack()
      );
      if (i != attacksNumber - 1) {
        assertEq(uint8(result), uint8(CombatSubsystem.CombatResult.NONE));
      }
    }
    assertEq(uint8(result), uint8(CombatSubsystem.CombatResult.DEFEAT));
    assertEq(playerCharstat.getLifeCurrent(), 0);
  }

  // player and encounter have the same stats and attacks, but player goes 1st and wins the last round
  function test_combatPVERound_opposedAttacks_victoryByInitiative() public {
    vm.prank(writer);

    CombatSubsystem.CombatResult result;
    // do enough attacks to defeat encounter
    uint256 attacksNumber = initLife / initAttack;
    for (uint256 i; i < attacksNumber; i++) {
      result = combatSubsystem.executePVERound(
        playerEntity, encounterEntity, _actions1Attack(), _actions1Attack()
      );
      if (i != attacksNumber - 1) {
        assertEq(uint8(result), uint8(CombatSubsystem.CombatResult.NONE));
      }
    }
    assertEq(uint8(result), uint8(CombatSubsystem.CombatResult.VICTORY));
    // also check that the last encounter action didn't go through, since it lost
    assertEq(playerCharstat.getLifeCurrent(), initLife - initAttack * (attacksNumber - 1));
    assertEq(encounterCharstat.getLifeCurrent(), 0);
  }

  // TODO So far just basic physical attacks. More tests, with statmods and skills.
}