// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { GenericDuration, GenericDurationData, EffectDurationTableId, DurationIdxMap } from "../src/codegen/index.sol";
import { Duration } from "../src/modules/duration/Duration.sol";

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
      EffectDurationTableId,
      targetEntity,
      app10,
      GenericDurationData({ timeId: timeId, timeValue: 10 })
    );
    // Increase app5 by 5
    Duration.increase(EffectDurationTableId, targetEntity, app5, GenericDurationData({ timeId: timeId, timeValue: 5 }));
  }

  function testIncreaseDuration() public {
    _increaseApps();

    GenericDurationData memory duration = Duration.get(EffectDurationTableId, targetEntity, app10);
    assertEq(duration.timeId, timeId);
    assertEq(duration.timeValue, 10);

    assertEq(Duration.getTimeId(EffectDurationTableId, targetEntity, app10), timeId);
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app10), 10);

    _increaseApps();

    duration = Duration.get(EffectDurationTableId, targetEntity, app10);
    assertEq(duration.timeId, timeId);
    assertEq(duration.timeValue, 20);

    assertEq(Duration.getTimeId(EffectDurationTableId, targetEntity, app10), timeId);
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app10), 20);
  }

  function testDecreaseApplications() public {
    _increaseApps();

    assertTrue(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, app10));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app10), 10);
    assertTrue(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, app5));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app5), 5);

    // Decrease by 5
    Duration.decreaseApplications(
      EffectDurationTableId,
      targetEntity,
      GenericDurationData({ timeId: timeId, timeValue: 5 })
    );

    assertTrue(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, app10));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app10), 5);
    assertFalse(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, app5));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app5), 0);

    // anotherTimeId shouldn't affect timeId
    Duration.decreaseApplications(
      EffectDurationTableId,
      targetEntity,
      GenericDurationData({ timeId: anotherTimeId, timeValue: 5 })
    );

    assertTrue(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, app10));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app10), 5);
    assertFalse(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, app5));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app5), 0);

    // Decrease by 5
    Duration.decreaseApplications(
      EffectDurationTableId,
      targetEntity,
      GenericDurationData({ timeId: timeId, timeValue: 5 })
    );

    assertFalse(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, app10));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app10), 0);
    assertFalse(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, app5));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app5), 0);
  }

  function testRemove() public {
    _increaseApps();

    Duration.remove(EffectDurationTableId, targetEntity, app10);
    // Check the removed entity
    assertFalse(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, app10));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app10), 0);
    // The other entity should be unaffected
    assertTrue(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, app5));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, app5), 5);
  }
}
