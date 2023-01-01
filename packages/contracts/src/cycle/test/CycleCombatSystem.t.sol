// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { getGuiseProtoEntity } from "../../guise/GuisePrototypeComponent.sol";
import { MapPrototypes } from "../../map/MapPrototypes.sol";
import { Loot } from "../../loot/LootComponent.sol";
import { AffixPartId } from "../../affix/LibPickAffixes.sol";
import { Action, ActionType, CombatSubsystem } from "../../combat/CombatSubsystem.sol";

contract CycleCombatSystemTest is BaseTest {
  // taken from InitGuiseSystem, initialized by LibDeploy
  uint256 warriorGuiseProtoEntity = getGuiseProtoEntity("Warrior");

  uint256 wandererEntity;
  uint256 cycleEntity;
  uint256 mapEntity;

  function setUp() public virtual override {
    super.setUp();

    vm.prank(alice);
    wandererEntity = wandererSpawnSystem.executeTyped(warriorGuiseProtoEntity);
    cycleEntity = activeCycleComponent.getValue(wandererEntity);

    // find a global basic level 1 map
    uint256[] memory mapEntities = fromPrototypeComponent.getEntitiesWithValue(MapPrototypes.GLOBAL_BASIC);
    for (uint256 i; i < mapEntities.length; i++) {
      if (_getMapLevel(mapEntities[i]) == 1) {
        mapEntity = mapEntities[i];
      }
    }
  }

  function _getMapLevel(uint256 mapEntity_) internal view returns (uint256) {
    Loot memory loot = lootComponent.getValue(mapEntity_);
    for (uint256 i; i < loot.affixPartIds.length; i++) {
      if (loot.affixPartIds[i] == AffixPartId.IMPLICIT) {
        return loot.affixValues[i];
      }
    }
    revert("_getMapLevel: no IMPLICIT");
  }

  function test_setUp() public {
    assertNotEq(mapEntity, 0);
  }

  function test_cycleCombat() public {
    vm.startPrank(alice);
    cycleActivateCombatSystem.executeTyped(
      wandererEntity,
      mapEntity
    );

    Action[] memory attackAction = new Action[](1);
    attackAction[0] = Action({
      actionType: ActionType.ATTACK,
      actionEntity: 0
    });

    CombatSubsystem.CombatResult result = CombatSubsystem.CombatResult.NONE;
    while (result == CombatSubsystem.CombatResult.NONE) {
      result = cycleCombatSystem.executeTyped(
        wandererEntity,
        attackAction
      );
    }
    // TODO test combat results, atm this just makes sure it can start/finish at all
  }
}