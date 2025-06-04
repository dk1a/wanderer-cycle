// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorldErrors } from "@latticexyz/world/src/IWorldErrors.sol";
import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";
import { BaseTest } from "./BaseTest.t.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { CombatActors, CombatStatus } from "../src/namespaces/combat/codegen/index.sol";
import { entitySystem } from "../src/namespaces/evefrontier/codegen/systems/EntitySystemLib.sol";
import { charstatSystem } from "../src/namespaces/charstat/codegen/systems/CharstatSystemLib.sol";
import { combatSystem } from "../src/namespaces/combat/codegen/systems/CombatSystemLib.sol";
import { CombatSystem, CombatAction, CombatActionType } from "../src/namespaces/combat/CombatSystem.sol";
import { LibSOFClass } from "../src/namespaces/common/LibSOFClass.sol";
import { LibSOFAccess } from "../src/namespaces/evefrontier/LibSOFAccess.sol";
import { LibCharstat } from "../src/namespaces/charstat/LibCharstat.sol";
import { LibCombatStatus } from "../src/namespaces/combat/LibCombatStatus.sol";
import { PStat, PStat_length, EleStat_length } from "../src/CustomTypes.sol";
import { StatmodTopics } from "../src/namespaces/statmod/StatmodTopic.sol";
import { Statmod } from "../src/namespaces/statmod/Statmod.sol";
import { EleStat, StatmodOp, CombatResult } from "../src/codegen/common.sol";

// Public library to create a non-zero callstack for expectRevert to work well, but preserve context via delegatecall
library RevertHelper {
  function combatStatusInitialize(bytes32 combatEntity, uint32 roundsMax) public {
    LibCombatStatus.initialize(combatEntity, roundsMax);
  }

  function combatStatusSpendRound(bytes32 combatEntity) public {
    LibCombatStatus.spendRound(combatEntity);
  }
}

contract CombatSystemTest is BaseTest {
  ResourceId actionSystemId;
  IWorld actionSystemMock;
  ResourceId[] actionSystemIds;

  bytes32 playerEntity;
  bytes32 encounterEntity;
  bytes32 combatEntity;

  CombatAction[] _noActions;

  // default data
  uint32 constant initLevel = 2;
  uint32 initLife;
  uint32 initAttack;
  uint32 defaultMaxRounds = 12;

  // statmod entities
  bytes32 levelStatmodEntity;

  function setUp() public virtual override {
    super.setUp();

    levelStatmodEntity = StatmodTopics.LEVEL.toStatmodEntity(StatmodOp.BADD, EleStat.NONE);

    // These entity classes are used as arguments only within combat activation
    // scopedSystemMock is used for activation
    _addToScope("test", combatSystem.toResourceId());
    _addToScope("test2", combatSystem.toResourceId());

    // actionSystemMock is used for combat actions
    (actionSystemId, actionSystemMock) = _createSystemMock("test_combatact", "actionSystem");
    // systems that have combat action access are passed as an activation argument
    actionSystemIds = new ResourceId[](1);
    actionSystemIds[0] = actionSystemId;

    vm.startPrank(deployer);

    // create player and encounter entities
    playerEntity = LibSOFClass.instantiate("test", deployer);
    encounterEntity = LibSOFClass.instantiate("test2", deployer);

    // give direct levels
    // (note: don't change statmods directly outside of tests, use effects)
    Statmod.increase(playerEntity, levelStatmodEntity, initLevel);
    Statmod.increase(encounterEntity, levelStatmodEntity, initLevel);

    // initialize and fill up life, mana
    charstatSystem.setFullCurrents(playerEntity);
    charstatSystem.setFullCurrents(encounterEntity);

    vm.stopPrank();

    initLife = LibCharstat.getLifeCurrent(playerEntity);
    initAttack = LibCharstat.getAttack(playerEntity)[uint256(EleStat.PHYSICAL)];
  }

  // ================ HELPERS ================

  function _activateCombat(uint32 maxRounds) internal {
    // activate combat between player and encounter
    combatEntity = scopedSystemMock.combat__activateCombat(playerEntity, encounterEntity, maxRounds, actionSystemIds);
  }

  function _sumElements(uint32[EleStat_length] memory elemValues) internal pure returns (uint32 result) {
    // TODO elemental values could use their own library, or at least some helpers
    for (uint256 i = 1; i < EleStat_length; i++) {
      result += elemValues[i];
    }
  }

  function _actions1Attack() internal pure returns (CombatAction[] memory result) {
    result = new CombatAction[](1);
    result[0] = CombatAction({ actionType: CombatActionType.ATTACK, actionEntity: 0 });
  }

  function _actions2Attacks() internal pure returns (CombatAction[] memory result) {
    result = new CombatAction[](2);
    result[0] = CombatAction({ actionType: CombatActionType.ATTACK, actionEntity: 0 });
    result[1] = CombatAction({ actionType: CombatActionType.ATTACK, actionEntity: 0 });
  }

  // ================ TESTS ================

  // this just shows the values I expect, and may need to change if LibCharstat config changes
  function testSetUp() public {
    _activateCombat(defaultMaxRounds);

    assertEq(CombatStatus.getIsInitialized(combatEntity), true);
    assertEq(uint8(CombatStatus.getCombatResult(combatEntity)), uint8(CombatResult.NONE));
    assertEq(CombatStatus.getRoundsSpent(combatEntity), 0);
    assertEq(CombatStatus.getRoundsMax(combatEntity), defaultMaxRounds);

    assertEq(CombatActors.getInitiatorEntity(combatEntity), playerEntity);
    assertEq(CombatActors.getRetaliatorEntity(combatEntity), encounterEntity);

    assertEq(initLife, 2 + 2 * initLevel);
    assertEq(LibCharstat.getLifeCurrent(playerEntity), LibCharstat.getLifeCurrent(encounterEntity));

    assertEq(initAttack, 1 + initLevel / 2);
    assertEq(_sumElements(LibCharstat.getAttack(playerEntity)), initAttack);
    assertEq(_sumElements(LibCharstat.getAttack(playerEntity)), _sumElements(LibCharstat.getAttack(encounterEntity)));
  }

  function testActivateCombatDirectAccess() public {
    vm.prank(deployer);
    combatEntity = world.combat__activateCombat(playerEntity, encounterEntity, defaultMaxRounds, actionSystemIds);
    assertEq(CombatStatus.getIsInitialized(combatEntity), true);

    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(LibSOFAccess.SOFAccess_AccessDenied.selector, playerEntity, alice));
    combatEntity = world.combat__activateCombat(playerEntity, encounterEntity, defaultMaxRounds, actionSystemIds);
  }

  function testActivateCombatPartialAccessDenied() public {
    vm.startPrank(deployer);
    // make writer own only the first entity - playerEntity
    playerEntity = LibSOFClass.instantiate("cycle", alice);
    encounterEntity = LibSOFClass.instantiate("cycle_encounter", deployer);
    vm.stopPrank();

    // writer will be denied access because of the second entity - encounterEntity
    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(LibSOFAccess.SOFAccess_AccessDenied.selector, encounterEntity, alice));
    combatEntity = world.combat__activateCombat(playerEntity, encounterEntity, defaultMaxRounds, actionSystemIds);
  }

  function testCombatPVERoundRevertInvalidEntityType() public {
    _activateCombat(defaultMaxRounds);

    vm.expectPartialRevert(SmartObjectFramework.SOF_InvalidEntityType.selector);
    actionSystemMock.combat__actPVERound(bytes32("invalid entity"), _noActions, _noActions);
  }

  function testCombatPVERoundRevertUnscopedEntity() public {
    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, emptyEntity, actionSystemId)
    );
    actionSystemMock.combat__actPVERound(emptyEntity, _noActions, _noActions);
  }

  function testCombatPVERoundRevertUnscopedSystem() public {
    _activateCombat(defaultMaxRounds);

    // only actionSystem is scoped for combatEntity
    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, combatEntity, scopedSystemId)
    );
    scopedSystemMock.combat__actPVERound(combatEntity, _noActions, _noActions);

    // emptySystem is not scoped for anything
    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, combatEntity, emptySystemId)
    );
    emptySystemMock.combat__actPVERound(combatEntity, _noActions, _noActions);
  }

  function testCombatPVERoundRevertDirectCall() public {
    _activateCombat(defaultMaxRounds);

    // TODO test system that doesn't go through world
    // No non-system address should be able to call the system directly (the access role was renounced)
    address[4] memory addresses = [address(0), address(this), alice, deployer];
    for (uint256 i = 0; i < addresses.length; i++) {
      address _address = addresses[i];
      vm.prank(_address);
      vm.expectRevert(abi.encodeWithSelector(LibSOFAccess.SOFAccess_AccessDenied.selector, combatEntity, _address));
      world.combat__actPVERound(combatEntity, _noActions, _noActions);
    }
  }

  function testCombatPVERoundRevertDoubleInit() public {
    _activateCombat(defaultMaxRounds);

    vm.expectPartialRevert(LibCombatStatus.LibCombatStatus_DuplicateInit.selector);
    RevertHelper.combatStatusInitialize(combatEntity, defaultMaxRounds);
  }

  function testCombatPVERoundRevertNotInitialized() public {
    vm.startPrank(deployer);
    bytes32 uninitializedCombatEntity = LibSOFClass.instantiate("combat", deployer);
    entitySystem.addToScope(uint256(uninitializedCombatEntity), actionSystemIds);
    vm.stopPrank();

    vm.expectPartialRevert(LibCombatStatus.LibCombatStatus_NotInitialized.selector);
    actionSystemMock.combat__actPVERound(uninitializedCombatEntity, _noActions, _noActions);
  }

  // skipping a round is fine
  function testCombatPVERoundNoActions() public {
    _activateCombat(defaultMaxRounds);

    CombatResult result = actionSystemMock.combat__actPVERound(combatEntity, _noActions, _noActions);
    assertEq(uint8(result), uint8(CombatResult.NONE));
  }

  // by default entities can only do 1 action per round
  function testCombatPVERoundRevertInvalidActionsLength() public {
    _activateCombat(defaultMaxRounds);

    vm.expectRevert(CombatSystem.CombatSystem_InvalidActionsLength.selector);
    actionSystemMock.combat__actPVERound(combatEntity, _actions2Attacks(), _actions2Attacks());
  }

  // an unopposed single attack
  function testCombatPVERoundPlayerAttacks1() public {
    _activateCombat(defaultMaxRounds);

    CombatResult result = actionSystemMock.combat__actPVERound(combatEntity, _actions1Attack(), _noActions);
    assertEq(uint8(result), uint8(CombatResult.NONE));
    assertEq(uint8(CombatStatus.getCombatResult(combatEntity)), uint8(result));
    assertEq(LibCharstat.getLifeCurrent(encounterEntity), initLife - initAttack);
  }

  // unopposed player attacks, enough to get victory
  function testCombatPVERoundPlayerAttacksVictory() public {
    _activateCombat(defaultMaxRounds);

    CombatResult result;
    // do enough attacks to defeat encounter
    uint256 attacksNumber = initLife / initAttack;
    for (uint256 i; i < attacksNumber; i++) {
      result = actionSystemMock.combat__actPVERound(combatEntity, _actions1Attack(), _noActions);
      if (i != attacksNumber - 1) {
        assertEq(uint8(result), uint8(CombatResult.NONE));
        assertEq(uint8(CombatStatus.getCombatResult(combatEntity)), uint8(result));
      }
    }
    assertEq(uint8(result), uint8(CombatResult.VICTORY));
    assertEq(uint8(CombatStatus.getCombatResult(combatEntity)), uint8(result));
    assertEq(LibCharstat.getLifeCurrent(encounterEntity), 0);

    vm.expectPartialRevert(LibCombatStatus.LibCombatStatus_CombatIsOver.selector);
    actionSystemMock.combat__actPVERound(combatEntity, _noActions, _noActions);
  }

  // unopposed encounter attacks, enough to get defeat
  function testCombatPVERoundEncounterAttacksDefeat() public {
    _activateCombat(defaultMaxRounds);

    CombatResult result;
    // do enough attacks to defeat player
    uint256 attacksNumber = initLife / initAttack;
    for (uint256 i; i < attacksNumber; i++) {
      result = actionSystemMock.combat__actPVERound(combatEntity, _noActions, _actions1Attack());
      if (i != attacksNumber - 1) {
        assertEq(uint8(result), uint8(CombatResult.NONE));
        assertEq(uint8(CombatStatus.getCombatResult(combatEntity)), uint8(result));
      }
    }
    assertEq(uint8(result), uint8(CombatResult.DEFEAT));
    assertEq(uint8(CombatStatus.getCombatResult(combatEntity)), uint8(result));
    assertEq(LibCharstat.getLifeCurrent(playerEntity), 0);

    vm.expectPartialRevert(LibCombatStatus.LibCombatStatus_CombatIsOver.selector);
    actionSystemMock.combat__actPVERound(combatEntity, _noActions, _noActions);
  }

  // player and encounter have the same stats and attacks, but player goes 1st and wins the last round
  function testCombatPVERoundOpposedAttacksVictoryByInitiative() public {
    _activateCombat(defaultMaxRounds);

    CombatResult result;
    // do enough attacks to defeat encounter
    uint256 attacksNumber = initLife / initAttack;
    for (uint256 i; i < attacksNumber; i++) {
      result = actionSystemMock.combat__actPVERound(combatEntity, _actions1Attack(), _actions1Attack());
      if (i != attacksNumber - 1) {
        assertEq(uint8(result), uint8(CombatResult.NONE));
        assertEq(uint8(CombatStatus.getCombatResult(combatEntity)), uint8(result));
      }
    }
    assertEq(uint8(result), uint8(CombatResult.VICTORY));
    assertEq(uint8(CombatStatus.getCombatResult(combatEntity)), uint8(result));
    // also check that the last encounter action didn't go through, since it lost
    assertEq(LibCharstat.getLifeCurrent(playerEntity), initLife - initAttack * (attacksNumber - 1));
    assertEq(LibCharstat.getLifeCurrent(encounterEntity), 0);
  }

  function testRoundDurationDecrease() public {
    _activateCombat(defaultMaxRounds);

    uint32 initialRoundsSpent = CombatStatus.getRoundsSpent(combatEntity);

    actionSystemMock.combat__actPVERound(combatEntity, _noActions, _noActions);

    uint32 roundsSpent = CombatStatus.getRoundsSpent(combatEntity);
    assertEq(roundsSpent, initialRoundsSpent + 1, "Rounds spent should increase by 1");
  }

  function testCombatDeactivatesAfterMaxRounds() public {
    _activateCombat(1);

    actionSystemMock.combat__actPVERound(combatEntity, _noActions, _noActions);
    assertEq(CombatStatus.getIsInitialized(combatEntity), true);
    assertEq(uint8(CombatStatus.getCombatResult(combatEntity)), uint8(CombatResult.DEFEAT));
    assertEq(CombatStatus.getRoundsSpent(combatEntity), 1);
    assertEq(CombatStatus.getRoundsMax(combatEntity), 1);

    vm.expectPartialRevert(LibCombatStatus.LibCombatStatus_CombatIsOver.selector);
    actionSystemMock.combat__actPVERound(combatEntity, _noActions, _noActions);
  }

  function testRevertRoundsOverMax() public {
    _activateCombat(1);

    LibCombatStatus.spendRound(combatEntity);
    vm.expectPartialRevert(LibCombatStatus.LibCombatStatus_RoundsOverMax.selector);
    RevertHelper.combatStatusSpendRound(combatEntity);
  }

  // TODO So far just basic physical attacks. More tests, with statmods and skills.
}
