// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { CycleClaimTurnsSystem } from "../../CycleClaimTurnsSystem.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";
import { IWorldCall } from "@latticexyz/world/src/IWorldKernel.sol";
import { SystemCall } from "@latticexyz/world/src/SystemCall.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

type CycleClaimTurnsSystemType is bytes32;

// equivalent to WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: "cycle", name: "CycleClaimTurnsS" }))
CycleClaimTurnsSystemType constant cycleClaimTurnsSystem = CycleClaimTurnsSystemType.wrap(
  0x73796379636c650000000000000000004379636c65436c61696d5475726e7353
);

struct CallWrapper {
  ResourceId systemId;
  address from;
}

struct RootCallWrapper {
  ResourceId systemId;
  address from;
}

/**
 * @title CycleClaimTurnsSystemLib
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This library is automatically generated from the corresponding system contract. Do not edit manually.
 */
library CycleClaimTurnsSystemLib {
  error CycleClaimTurnsSystemLib_CallingFromRootSystem();

  function claimTurns(CycleClaimTurnsSystemType self, bytes32 cycleEntity) internal {
    return CallWrapper(self.toResourceId(), address(0)).claimTurns(cycleEntity);
  }

  function claimTurns(CallWrapper memory self, bytes32 cycleEntity) internal {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert CycleClaimTurnsSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(_claimTurns_bytes32.claimTurns, (cycleEntity));
    self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
  }

  function claimTurns(RootCallWrapper memory self, bytes32 cycleEntity) internal {
    bytes memory systemCall = abi.encodeCall(_claimTurns_bytes32.claimTurns, (cycleEntity));
    SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
  }

  function callFrom(CycleClaimTurnsSystemType self, address from) internal pure returns (CallWrapper memory) {
    return CallWrapper(self.toResourceId(), from);
  }

  function callAsRoot(CycleClaimTurnsSystemType self) internal view returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), WorldContextConsumerLib._msgSender());
  }

  function callAsRootFrom(CycleClaimTurnsSystemType self, address from) internal pure returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), from);
  }

  function toResourceId(CycleClaimTurnsSystemType self) internal pure returns (ResourceId) {
    return ResourceId.wrap(CycleClaimTurnsSystemType.unwrap(self));
  }

  function fromResourceId(ResourceId resourceId) internal pure returns (CycleClaimTurnsSystemType) {
    return CycleClaimTurnsSystemType.wrap(resourceId.unwrap());
  }

  function getAddress(CycleClaimTurnsSystemType self) internal view returns (address) {
    return Systems.getSystem(self.toResourceId());
  }

  function _world() private view returns (IWorldCall) {
    return IWorldCall(StoreSwitch.getStoreAddress());
  }
}

/**
 * System Function Interfaces
 *
 * We generate an interface for each system function, which is then used for encoding system calls.
 * This is necessary to handle function overloading correctly (which abi.encodeCall cannot).
 *
 * Each interface is uniquely named based on the function name and parameters to prevent collisions.
 */

interface _claimTurns_bytes32 {
  function claimTurns(bytes32 cycleEntity) external;
}

using CycleClaimTurnsSystemLib for CycleClaimTurnsSystemType global;
using CycleClaimTurnsSystemLib for CallWrapper global;
using CycleClaimTurnsSystemLib for RootCallWrapper global;
