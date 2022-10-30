// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { LibScoped, getSVComponents, SVComponents } from "@wanderer-cycle/std/contracts/LibScoped.sol";
import { TBScopeComponent, ID as TBScopeComponentID } from "./TBScopeComponent.sol";
import { TBTimeComponent, ID as TBTimeComponentID, TBTime } from "./TBTimeComponent.sol";

/**
 * @title Logic for turn-based time components, primarily scoped increase/decrease.
 * @dev Also see LibScoped for some abstracted scoping logic (without generics it doesn't help much though).
 * 
 * Entity can have durations and scope.
 * Duration is TBTime, which has timeType and timeValue.
 * Ongoing duration means timeValue > 0.
 * 
 * TimeValue is the duration.
 * TimeType is the meaning of the duration (e.g. round, day...).
 * Changing an ongoing timeValue with a different timeType will revert.
 * 
 * Scope and timeType create scopeEntity, which lets LibScoped get all entities/values within given scope.
 * (e.g. skill cooldowns: user is scope, skill is entity,
 * cooldown duration is timeValue, timeType can vary between skills).
 */
library LibTurnBasedTime {
    error LibTurnBasedTime__IncreaseByZero(uint256 entity);
    error LibTurnBasedTime__DecreaseByZero(uint256 scope, uint256 timeType);

    // ========== UTILS ==========

    function svc(address components) internal view returns (SVComponents memory) {
        return getSVComponents(components, TBScopeComponentID, TBTimeComponentID);
    }

    function getScopeEntity(uint256 scope, TBTime memory time) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(scope, time.timeType)));
    }

    // ========== READ ==========

    /**
     * @dev True if entity's duration is ongoing, false otherwise
     */
    function has(
        SVComponents memory _svc,
        uint256 entity
    ) internal view returns (bool) {
        return LibScoped.has(_svc, entity);
    }

    /**
     * @dev Return duration for given entity.
     */
    function get(
        SVComponents memory _svc,
        uint256 entity
    ) internal view returns (TBTime memory time) {
        return abi.decode(
            LibScoped.get(_svc, entity),
            (TBTime)
        );
    }

    // ========== WRITE ==========

    /**
     * @notice Increase entity's duration
     * @return isUpdate true if updated, false if created (update only changes TBTimeComponent)
     * 
     * @dev For updates scope/time.timeType must match what was used at creation
     */
    function increase(
        SVComponents memory _svc,
        uint256 scope,
        uint256 entity,
        TBTime memory time,
    ) internal returns (bool isUpdate) {
        // zero increase is invalid
        if (time.timeValue == 0) {
            revert LibTurnBasedTime__IncreaseByZero(entity);
        }

        // compose scopeEntity
        uint256 scopeEntity = getScopeEntity(scope, time);

        // get stored data
        isUpdate = has(_svc, entity);
        TBTime memory storedTime = abi.decode(
            LibScoped.getOrCreate(_svc, scopeEntity, entity, abi.encode(time)),
            (TBTime)
        );

        if (isUpdate) {
            // increase value
            updateValue(_svc, entity, TBTime({
                timeType: storedTime.timeType,
                timeValue: storedTime.timeValue + time.timeValue
            }));
        }
    }

    /**
     * @notice Within given scope decrease all durations of time.timeType by time.timeValue.
     * @dev When a duration would become <= 0, it is removed instead.
     * @return removedEntities entities that were removed due to being <= 0
     */
    function decrease(
        SVComponents memory _svc,
        uint256 scope,
        TimeStruct memory time,
    ) internal returns (uint256[] memory) {
        // zero decrease is invalid
        if (time.timeValue == 0) {
            revert LibTurnBasedTime__DecreaseByZero(scope, time.timeType);
        }

        // compose scopeEntity
        uint256 scopeEntity = getScopeEntity(scope, time);

        uint256[] memory entities = LibScope.getEntitiesForScope(_svc, scopeEntity);
        // track removed entities
        uint256[] memory removedEntities = new uint256[](entities.length);
        uint256 removedLength;
        // loop all entities within scopeEntity
        for (uint256 i; i < entities.length; i++) {
            uint256 entity = entities[i];

            TBTime memory storedTime = get(_svc, entity);
            assert(storedTime.timeType == time.timeType);

            // if time decrease >= stored time
            if (time.timeValue >= storedTime.timeValue) {
                // remove
                remove(_svc, entity);

                removedEntities[removedLength++] = entity;
            } else {
                // decrease
                updateValue(_svc, entity, TBTime({
                    timeType: storedTime.timeType,
                    timeValue: storedTime.timeValue - time.timeValue
                }));
            }
        }

        // return removedEntities with unused space sliced off 
        if (removedEntities.length == removedLength) {
            return removedEntities;
        }
        bytes32[] memory removedEntitiesSliced = new bytes32[](removedLength);
        for (uint256 i; i < removedLength; i++) {
            removedEntitiesSliced[i] = removedEntities[i];
        }
        return removedEntitiesSliced;
    }

    /**
     * @notice Remove entity's duration.
     */
    function remove(
        SVComponents memory _svc,
        uint256 entity,
    ) internal {
        LibScope.remove(_svc, entity);
    }

    function updateValue(
        SVComponents memory _svc,
        uint256 entity,
        TBTime memory value
    ) private {
        LibScoped.updateValue(_svc, entity, abi.encode(value);
    }
}