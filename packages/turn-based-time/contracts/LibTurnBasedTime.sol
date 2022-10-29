// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@latticexyz/solecs/System.sol";
import { IWorld } from "@latticexyz/solecs/interfaces/IWorld.sol";
import { getAddressById, addressToEntity } from "@latticexyz/solecs/utils.sol";

import { TimeTypeComponent, ID as TimeTypeComponentID } from "../components/TimeTypeComponent.sol";
import { TimeValueComponent, ID as TimeValueComponentID } from "../components/TimeValueComponent.sol";

struct TimeStruct {
    uint256 timeType;
    uint256 timeValue;
}

library LibTurnBasedTime {
    function timeTypeComponent(address components) internal view returns (TimeTypeComponent) {
        return TimeTypeComponent(getAddressById(components, TimeTypeComponentID));
    }

    function timeValueComponent(address components) internal view returns (TimeValueComponent) {
        return TimeValueComponent(getAddressById(components, TimeValueComponentID));
    }

    /**
     * @dev True if entity's duration is ongoing, false otherwise
     */
    function isOngoing(
        address components,
        uint256 entity
    ) internal view returns (bool) {
        return timeValueComponent(components).getValue(entity) > 0;
    }

    /**
     * @dev True if given timeType doesn't match ongoing timeType
     * (always false if isOngoing == false)
     */
    function isMismatch(
        address components,
        uint256 entity,
        uint256 timeType
    ) internal view returns (bool) {
        return isOngoing(components, entity)
            && timeType !== timeTypeComponent(components).getValue(entity);
    }

    /**
     * @dev Increases entity's duration
     * 
     * If `id` has ongoing time, then supplied timeType must match ongoing timeType
     * (to change timeType remove ongoing time first)
     */
    function increase(
        address components,
        uint256 entity,
        uint256 timeType,
    ) internal {
        bool _isOngoing = map.isOngoing(id);

        if (time.timeValue == 0) {
            revert TurnBasedTimeMap__IncreaseByZero(id);
        }
        // changing ongoing timeType is bad - remove the old value first
        if (_isMismatch(_isOngoing, map._values[id].time, time)) {
            revert TurnBasedTimeMap__TimeTypeMismatch(id);
        }

        if (_isOngoing) {
            // increase
            map._values[id].time.timeValue += time.timeValue;
        } else {
            // initialize
            uint256 length = map._keys[time.timeType].length;
            map._keys[time.timeType].push(id);
            map._values[id] = TimeStructIndexed({
                time: time,
                // index is 1-based
                index: uint128(length) + 1
            });
        }
    }
}