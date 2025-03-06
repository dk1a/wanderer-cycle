// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { EffectDuration } from "../src/namespaces/effect/LibEffect.sol";
import { Duration, GenericDuration, GenericDurationData, Idx_GenericDuration_TargetEntityTimeId } from "../src/namespaces/duration/Duration.sol";

contract DurationTest is MudLibTest {
  bytes32 targetEntity = keccak256("targetEntity");
  bytes32 app10 = keccak256("app10");
  bytes32 app5 = keccak256("app5");

  bytes32 timeId = keccak256("timeId");
  bytes32 anotherTimeId = keccak256("anotherTimeId");

  function setUp() public virtual override {
    super.setUp();
  }

  function _increaseApps() internal {
    // Increase app10 by 10
    Duration.increase(
      EffectDuration._tableId,
      targetEntity,
      app10,
      GenericDurationData({ timeId: timeId, timeValue: 10 })
    );
    // Increase app5 by 5
    Duration.increase(
      EffectDuration._tableId,
      targetEntity,
      app5,
      GenericDurationData({ timeId: timeId, timeValue: 5 })
    );
  }

  function testIncreaseDuration() public {
    _increaseApps();

    GenericDurationData memory duration = Duration.get(EffectDuration._tableId, targetEntity, app10);
    assertEq(duration.timeId, timeId);
    assertEq(duration.timeValue, 10);

    assertEq(Duration.getTimeId(EffectDuration._tableId, targetEntity, app10), timeId);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app10), 10);

    _increaseApps();

    duration = Duration.get(EffectDuration._tableId, targetEntity, app10);
    assertEq(duration.timeId, timeId);
    assertEq(duration.timeValue, 20);

    assertEq(Duration.getTimeId(EffectDuration._tableId, targetEntity, app10), timeId);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app10), 20);
  }

  function testDecreaseApplications() public {
    _increaseApps();

    (bool has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, app10);
    assertTrue(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app10), 10);
    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, app5);
    assertTrue(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app5), 5);

    // Decrease by 5
    Duration.decreaseApplications(
      EffectDuration._tableId,
      targetEntity,
      GenericDurationData({ timeId: timeId, timeValue: 5 })
    );

    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, app10);
    assertTrue(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app10), 5);
    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, app5);
    assertFalse(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app5), 0);

    // anotherTimeId shouldn't affect timeId
    Duration.decreaseApplications(
      EffectDuration._tableId,
      targetEntity,
      GenericDurationData({ timeId: anotherTimeId, timeValue: 5 })
    );

    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, app10);
    assertTrue(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app10), 5);
    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, app5);
    assertFalse(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app5), 0);

    // Decrease by 5
    Duration.decreaseApplications(
      EffectDuration._tableId,
      targetEntity,
      GenericDurationData({ timeId: timeId, timeValue: 5 })
    );

    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, app10);
    assertFalse(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app10), 0);
    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, app5);
    assertFalse(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app5), 0);
  }

  function testRemove() public {
    _increaseApps();

    Duration.remove(EffectDuration._tableId, targetEntity, app10);
    // Check the removed entity
    (bool has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, app10);
    assertFalse(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app10), 0);
    // The other entity should be unaffected
    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, app5);
    assertTrue(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, app5), 5);
  }
}
