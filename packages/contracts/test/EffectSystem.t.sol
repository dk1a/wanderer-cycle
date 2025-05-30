// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";
import { BaseTest } from "./BaseTest.t.sol";

import { effectSystem } from "../src/namespaces/effect/codegen/systems/EffectSystemLib.sol";
import { effectTemplateSystem, EffectTemplateData } from "../src/namespaces/effect/codegen/systems/EffectTemplateSystemLib.sol";
import { LibSOFClass } from "../src/namespaces/common/LibSOFClass.sol";
import { LibEffect, EffectDuration } from "../src/namespaces/effect/LibEffect.sol";
import { makeEffectTemplate } from "../src/namespaces/effect/makeEffectTemplate.sol";
import { Duration, GenericDurationData, Idx_GenericDuration_TargetEntityTimeId } from "../src/namespaces/duration/Duration.sol";
import { StatmodTopics, StatmodOp, EleStat } from "../src/namespaces/statmod/StatmodTopic.sol";

contract EffectSystemTest is BaseTest {
  bytes32 targetEntity;
  bytes32 applicationEntity;

  bytes32 timeId = keccak256("timeId");
  bytes32 anotherTimeId = keccak256("anotherTimeId");

  function setUp() public virtual override {
    super.setUp();

    vm.startPrank(deployer);
    targetEntity = LibSOFClass.instantiate("test", deployer);
    applicationEntity = LibSOFClass.instantiate("test2", deployer);
    vm.stopPrank();

    scopedSystemMock.effect__setEffectTemplate(
      applicationEntity,
      makeEffectTemplate(StatmodTopics.LIFE, StatmodOp.ADD, EleStat.NONE, 10)
    );
  }

  function testRevertUnscoped() public {
    EffectTemplateData memory effectTemplateData = makeEffectTemplate(
      StatmodTopics.LIFE,
      StatmodOp.ADD,
      EleStat.NONE,
      10
    );

    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, applicationEntity, emptySystemId)
    );
    emptySystemMock.effect__setEffectTemplate(applicationEntity, effectTemplateData);

    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, targetEntity, emptySystemId)
    );
    emptySystemMock.effect__applyEffect(targetEntity, applicationEntity);

    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, targetEntity, emptySystemId)
    );
    emptySystemMock.effect__applyTimedEffect(
      targetEntity,
      applicationEntity,
      GenericDurationData({ timeId: timeId, timeValue: 10 })
    );

    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, targetEntity, emptySystemId)
    );
    emptySystemMock.effect__removeEffect(targetEntity, applicationEntity);
  }

  function testDecreaseApplications() public {
    // Apply effect and duration
    scopedSystemMock.effect__applyTimedEffect(
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
    scopedSystemMock.effect__applyEffect(targetEntity, applicationEntity);

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
