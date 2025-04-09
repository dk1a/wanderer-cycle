// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { BaseTest } from "./BaseTest.t.sol";

import { CombatAction, CombatActionType } from "../src/CustomTypes.sol";
import { ActiveCycle, LootAffixes } from "../src/namespaces/root/codegen/index.sol";
import { Affix } from "../src/namespaces/affix/codegen/index.sol";
import { AffixPartId } from "../src/namespaces/affix/types.sol";
import { LibGuise } from "../src/namespaces/root/guise/LibGuise.sol";
import { LibInitMapsGlobal } from "../src/namespaces/root/init/LibInitMapsGlobal.sol";
import { CombatResult } from "../src/codegen/common.sol";

contract CycleCombatSystemTest is BaseTest {
  // taken from InitGuiseSystem, initialized by LibDeploy
  bytes32 guiseEntity;

  bytes32 wandererEntity;
  bytes32 cycleEntity;
  bytes32 mapEntity;

  function setUp() public virtual override {
    super.setUp();

    guiseEntity = LibGuise.getGuiseEntity("Warrior");

    vm.prank(alice);
    (wandererEntity, cycleEntity) = world.spawnWanderer(guiseEntity);

    // make a basic level 1 map
    mapEntity = LibInitMapsGlobal.makeBasic(1);
  }

  function _getMapLevel(bytes32 _mapEntity) internal view returns (uint256) {
    bytes32[] memory affixEntities = LootAffixes.get(_mapEntity);
    for (uint256 i; i < affixEntities.length; i++) {
      if (Affix.getPartId(affixEntities[i]) == AffixPartId.IMPLICIT) {
        Affix.getValue(affixEntities[i]);
      }
    }
    revert("_getMapLevel: no IMPLICIT");
  }

  function testSetUp() public {
    assertNotEq(guiseEntity, bytes32(0));
    assertNotEq(wandererEntity, bytes32(0));
    assertNotEq(cycleEntity, bytes32(0));
    assertNotEq(mapEntity, bytes32(0));
  }

  function testCycleCombat() public {
    vm.startPrank(alice);

    world.activateCycleCombat(cycleEntity, mapEntity);

    CombatAction[] memory attackAction = new CombatAction[](1);
    attackAction[0] = CombatAction({ actionType: CombatActionType.ATTACK, actionEntity: 0 });

    CombatResult result = CombatResult.NONE;
    while (result == CombatResult.NONE) {
      result = world.processCycleCombatRound(cycleEntity, attackAction);
    }
    assertEq(uint8(result), uint8(CombatResult.VICTORY));
    // TODO test combat results, atm this just makes sure it can start/finish at all
  }
}
