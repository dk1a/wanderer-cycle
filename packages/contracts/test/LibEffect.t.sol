// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { GenericDurationData, DurationIdxMap, EffectDurationTableId, EffectTemplateData } from "../src/codegen/index.sol";
import { Duration } from "../src/modules/duration/Duration.sol";
import { LibEffect } from "../src/modules/effect/LibEffect.sol";
import { LibEffectTemplate } from "../src/modules/effect/LibEffectTemplate.sol";
import { StatmodTopics, StatmodOp, EleStat } from "../src/modules/statmod/StatmodTopic.sol";

contract LibEffectTest is MudLibTest {
  bytes32 targetEntity = keccak256("targetEntity");
  bytes32 applicationEntity = keccak256("applicationEntity");

  bytes32 timeId = keccak256("timeId");
  bytes32 anotherTimeId = keccak256("anotherTimeId");

  bytes32 lifeEntity = StatmodTopics.LIFE.toStatmodEntity(StatmodOp.ADD, EleStat.NONE);

  function setUp() public virtual override {
    super.setUp();

    EffectTemplateData memory effectTemplate = EffectTemplateData({
      entities: new bytes32[](1),
      values: new uint32[](1)
    });
    effectTemplate.entities[0] = lifeEntity;
    effectTemplate.values[0] = 10;

    LibEffectTemplate.verifiedSet(applicationEntity, effectTemplate);
  }

  function testDecreaseApplications() public {
    // Apply effect and duration
    LibEffect.applyTimedEffect(targetEntity, applicationEntity, GenericDurationData({ timeId: timeId, timeValue: 10 }));

    assertTrue(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    assertTrue(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, applicationEntity));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, applicationEntity), 10);

    // Decrease duration by 5
    Duration.decreaseApplications(
      EffectDurationTableId,
      targetEntity,
      GenericDurationData({ timeId: timeId, timeValue: 5 })
    );

    assertTrue(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    assertTrue(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, applicationEntity));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, applicationEntity), 5);

    // anotherTimeId shouldn't affect timeId
    Duration.decreaseApplications(
      EffectDurationTableId,
      targetEntity,
      GenericDurationData({ timeId: anotherTimeId, timeValue: 5 })
    );

    assertTrue(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    assertTrue(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, applicationEntity));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, applicationEntity), 5);

    // Decrease duration by 5
    Duration.decreaseApplications(
      EffectDurationTableId,
      targetEntity,
      GenericDurationData({ timeId: timeId, timeValue: 5 })
    );

    assertFalse(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    assertFalse(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, applicationEntity));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, applicationEntity), 0);

    // Apply effect without duration
    LibEffect.applyEffect(targetEntity, applicationEntity);

    assertTrue(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    assertFalse(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, applicationEntity));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, applicationEntity), 0);

    // Decreasing absent duration shouldn't remove effect
    Duration.decreaseApplications(
      EffectDurationTableId,
      targetEntity,
      GenericDurationData({ timeId: timeId, timeValue: 10 })
    );

    assertTrue(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    assertFalse(DurationIdxMap.getHas(EffectDurationTableId, targetEntity, applicationEntity));
    assertEq(Duration.getTimeValue(EffectDurationTableId, targetEntity, applicationEntity), 0);
  }
}
