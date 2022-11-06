// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { LibScopedEffectValue } from "./LibScopedEffectValue.sol";

library LibEffect {
    // ========== UTILS ==========

    function getValueComponent(IUint256Component components) internal view returns (EffectValueComponent) {
        return EffectValueComponent(getAddressById(components, EffectValueComponentID));
    }

    function getScopeComponent(IUint256Component components) internal view returns (EffectScopeComponent) {
        return EffectScopeComponent(getAddressById(components, EffectScopeComponentID));
    }

    /*function getScopeEntity(uint256 scope, TBTime memory time) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(scope, time.timeType)));
    }*/

    // ========== READ ==========

    

    // ========== WRITE ==========

    
}