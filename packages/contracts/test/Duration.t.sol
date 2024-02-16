// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { GenericDuration, GenericDurationData, DurationIdxList, DurationIdxMap } from "../src/codegen/index.sol";
import { Duration } from "../src/modules/duration/Duration.sol";

contract DurationTest is MudLibTest {
  ResourceId _tableId = keccak256("_tableId");

  bytes32 targetEntity = keccak256("targetEntity");
  bytes32 applicationEntity = keccak256("applicationEntity");

  bytes32 timeId = keccak256("timeId");
  bytes32 anotherTimeScopeId = keccak256("anotherTimeId");

  function setUp() public {}

  function _increaseBy10() internal {
    Duration.increase(
      _tableId,
      targetEntity,
      applicationEntity,
      GenericDurationData({ timeId: timeId, timeValue: 10 })
    );
  }

  function testGetDuration() public {
    _increaseBy10();

    GenericDurationData memory duration = GenericDuration.get(_tableId, targetEntity, applicationEntity);
    assertEq(duration.timeId, timeId);
    assertEq(duration.timeValue, 10);

    uint256 timeValue = GenericDuration.getTimeValue(_tableId, targetEntity, applicationEntity);
    assertEq(timeValue, 10);
  }

  function testDecreaseScopeCallback() public {
    _increaseBy10();

    assertTrue(DurationIdxMap.getHas(_tableId, targetEntity, applicationEntity));

    Duration.decreaseApplications(_tableId, targetEntity, DurationValueData({ timeId: timeId, timeValue: 5 }));

    // not yet (it was 10 - 5)
    //    assertFalse(uintComponent.has(de1));
    assertTrue(DurationIdxMap.getHas(_tableId, targetEntity, applicationEntity));
    assertEq(GenericDuration.getTimeValue(_tableId, targetEntity, applicationEntity), 5);

    Duration.decreaseApplications(
      _tableId,
      targetEntity,
      DurationValueData({ timeScopeId: anotherTimeScopeId, timeValue: 5 })
    );

    // anotherTimeScopeId shouldn't have affected timeScopeId
    //    assertFalse(uintComponent.has(de1));
    assertTrue(DurationIdxMap.getHas(_tableId, targetEntity, applicationEntity));
    assertEq(GenericDuration.getTimeValue(_tableId, targetEntity, applicationEntity), 5);

    Duration.decreaseApplications(_tableId, targetEntity, ScopedDuration({ timeScopeId: timeScopeId, timeValue: 5 }));

    // now the callback must have been called
    //    assertEq(uintComponent.getValue(de1), 1337);
    assertFalse(DurationIdxMap.getHas(_tableId, targetEntity, applicationEntity));

    // remove the value and make sure the callback isn't called to set it again
    //    uintComponent.remove(de1);

    Duration.decreaseApplications(_tableId, targetEntity, ScopedDuration({ timeScopeId: timeScopeId, timeValue: 10 }));

    //    assertFalse(uintComponent.has(de1));
    assertFalse(DurationIdxMap.getHas(_tableId, targetEntity, applicationEntity));
  }

  function testRemoveNoCallback() public {
    _increaseBy10();

    GenericDurationData duration = GenericDuration.get(_tableId, targetEntity, applicationEntity);

    assertTrue(DurationIdxMap.getHas(DurationValue, targetEntity, applicationEntity));

    Duration.remove(_tableId, targetEntity, applicationEntity);

    assertFalse(DurationIdxMap.getHas(DurationValue, targetEntity, applicationEntity, applicationType));

    durationSubsystem.decreaseApplications(
      _tableId,
      targetEntity,
      DurationValueData({ timeId: timeId, timeValue: 10 })
    );

    assertFalse(DurationIdxMap.getHas(DurationValue, targetEntity, applicationEntity, applicationType));
  }
}
