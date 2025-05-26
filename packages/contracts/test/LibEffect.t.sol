// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseTest } from "./BaseTest.t.sol";
import { effectSystem } from "../src/namespaces/effect/codegen/systems/EffectSystemLib.sol";
import { effectTemplateSystem, EffectTemplateData } from "../src/namespaces/effect/codegen/systems/EffectTemplateSystemLib.sol";
import { Duration, GenericDurationData, Idx_GenericDuration_TargetEntityTimeId } from "../src/namespaces/duration/Duration.sol";
import { LibEffect, EffectDuration } from "../src/namespaces/effect/LibEffect.sol";
import { StatmodTopics, StatmodOp, EleStat } from "../src/namespaces/statmod/StatmodTopic.sol";

contract LibEffectTest is BaseTest {
  bytes32 targetEntity = keccak256("targetEntity");
  bytes32 applicationEntity = keccak256("applicationEntity");

  bytes32 timeId = keccak256("timeId");
  bytes32 anotherTimeId = keccak256("anotherTimeId");

  function setUp() public virtual override {
    super.setUp();

    bytes32 lifeAddEntity = StatmodTopics.LIFE.toStatmodEntity(StatmodOp.ADD, EleStat.NONE);

    EffectTemplateData memory effectTemplate = EffectTemplateData({
      statmodEntities: new bytes32[](1),
      values: new uint32[](1)
    });
    effectTemplate.statmodEntities[0] = lifeAddEntity;
    effectTemplate.values[0] = 10;

    effectTemplateSystem.setEffectTemplate(applicationEntity, effectTemplate);
  }

  function testDecreaseApplications() public {
    // Apply effect and duration
    effectSystem.applyTimedEffect(
      targetEntity,
      applicationEntity,
      GenericDurationData({ timeId: timeId, timeValue: 10 })
    );

    assertTrue(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    (bool has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, applicationEntity);
    assertTrue(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, applicationEntity), 10);

    // Decrease duration by 5
    Duration.decreaseApplications(
      EffectDuration._tableId,
      targetEntity,
      GenericDurationData({ timeId: timeId, timeValue: 5 })
    );

    assertTrue(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, applicationEntity);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, applicationEntity), 5);

    // anotherTimeId shouldn't affect timeId
    Duration.decreaseApplications(
      EffectDuration._tableId,
      targetEntity,
      GenericDurationData({ timeId: anotherTimeId, timeValue: 5 })
    );

    assertTrue(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, applicationEntity);
    assertTrue(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, applicationEntity), 5);

    // Decrease duration by 5
    Duration.decreaseApplications(
      EffectDuration._tableId,
      targetEntity,
      GenericDurationData({ timeId: timeId, timeValue: 5 })
    );

    assertFalse(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, applicationEntity);
    assertFalse(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, applicationEntity), 0);

    // Apply effect without duration
    effectSystem.applyEffect(targetEntity, applicationEntity);

    assertTrue(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, applicationEntity);
    assertFalse(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, applicationEntity), 0);

    // Decreasing absent duration shouldn't remove effect
    Duration.decreaseApplications(
      EffectDuration._tableId,
      targetEntity,
      GenericDurationData({ timeId: timeId, timeValue: 10 })
    );

    assertTrue(LibEffect.hasEffectApplied(targetEntity, applicationEntity));
    (has, ) = Idx_GenericDuration_TargetEntityTimeId.has(EffectDuration._tableId, targetEntity, applicationEntity);
    assertFalse(has);
    assertEq(Duration.getTimeValue(EffectDuration._tableId, targetEntity, applicationEntity), 0);
  }
}
