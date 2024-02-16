// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { MudLibTest } from "./MudLibTest.t.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { GenericDuration, GenericDurationData, DurationIdxList, DurationIdxMap } from "../src/codegen/index.sol";
import { Duration } from "../src/modules/duration/Duration.sol";

contract DurationTest2 is MudLibTest {
  ResourceId tableId;
  bytes32 targetEntity;
  bytes32 applicationEntity;
  GenericDurationData initialDuration;

  function setUp() public {
    tableId = keccak256("tableId");
    targetEntity = keccak256("targetEntity");
    applicationEntity = keccak256("applicationEntity");
    initialDuration = GenericDurationData({ timeId: keccak256("timeId"), timeValue: 0 });
  }

  function testIncreaseDuration() public {
    uint256 storedValue = GenericDuration.getTimeValue(tableId, targetEntity, applicationEntity);
    assertEq(storedValue, 0);

    bool isUpdate = Duration.increase(
      tableId,
      targetEntity,
      applicationEntity,
      GenericDurationData({ timeId: initialDuration.timeId, timeValue: 10 })
    );

    assertEq(isUpdate, false);
    storedValue = GenericDuration.getTimeValue(tableId, targetEntity, applicationEntity);
    assertEq(storedValue, 10);

    isUpdate = Duration.increase(
      tableId,
      targetEntity,
      applicationEntity,
      GenericDurationData({ timeId: initialDuration.timeId, timeValue: 5 })
    );
    assertEq(isUpdate, true);
    storedValue = GenericDuration.getTimeValue(tableId, targetEntity, applicationEntity);
    assertEq(storedValue, 15);
  }
}
