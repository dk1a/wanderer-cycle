// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { RNGSystem } from "../../RNGSystem.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";
import { IWorldCall } from "@latticexyz/world/src/IWorldKernel.sol";
import { SystemCall } from "@latticexyz/world/src/SystemCall.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

type RNGSystemType is bytes32;

// equivalent to WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: "rng", name: "RNGSystem" }))
RNGSystemType constant rNGSystem = RNGSystemType.wrap(
  0x7379726e670000000000000000000000524e4753797374656d00000000000000
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
 * @title RNGSystemLib
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This library is automatically generated from the corresponding system contract. Do not edit manually.
 */
library RNGSystemLib {
  error RNGSystemLib_CallingFromRootSystem();

  function requestRandomness(RNGSystemType self, bytes32 requestOwnerEntity) internal returns (bytes32 requestId) {
    return CallWrapper(self.toResourceId(), address(0)).requestRandomness(requestOwnerEntity);
  }

  function removeRequest(RNGSystemType self, bytes32 requestOwnerEntity, bytes32 requestId) internal {
    return CallWrapper(self.toResourceId(), address(0)).removeRequest(requestOwnerEntity, requestId);
  }

  function requestRandomness(CallWrapper memory self, bytes32 requestOwnerEntity) internal returns (bytes32 requestId) {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert RNGSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(_requestRandomness_bytes32.requestRandomness, (requestOwnerEntity));

    bytes memory result = self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
    return abi.decode(result, (bytes32));
  }

  function removeRequest(CallWrapper memory self, bytes32 requestOwnerEntity, bytes32 requestId) internal {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert RNGSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(
      _removeRequest_bytes32_bytes32.removeRequest,
      (requestOwnerEntity, requestId)
    );
    self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
  }

  function requestRandomness(
    RootCallWrapper memory self,
    bytes32 requestOwnerEntity
  ) internal returns (bytes32 requestId) {
    bytes memory systemCall = abi.encodeCall(_requestRandomness_bytes32.requestRandomness, (requestOwnerEntity));

    bytes memory result = SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
    return abi.decode(result, (bytes32));
  }

  function removeRequest(RootCallWrapper memory self, bytes32 requestOwnerEntity, bytes32 requestId) internal {
    bytes memory systemCall = abi.encodeCall(
      _removeRequest_bytes32_bytes32.removeRequest,
      (requestOwnerEntity, requestId)
    );
    SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
  }

  function callFrom(RNGSystemType self, address from) internal pure returns (CallWrapper memory) {
    return CallWrapper(self.toResourceId(), from);
  }

  function callAsRoot(RNGSystemType self) internal view returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), WorldContextConsumerLib._msgSender());
  }

  function callAsRootFrom(RNGSystemType self, address from) internal pure returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), from);
  }

  function toResourceId(RNGSystemType self) internal pure returns (ResourceId) {
    return ResourceId.wrap(RNGSystemType.unwrap(self));
  }

  function fromResourceId(ResourceId resourceId) internal pure returns (RNGSystemType) {
    return RNGSystemType.wrap(resourceId.unwrap());
  }

  function getAddress(RNGSystemType self) internal view returns (address) {
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

interface _requestRandomness_bytes32 {
  function requestRandomness(bytes32 requestOwnerEntity) external;
}

interface _removeRequest_bytes32_bytes32 {
  function removeRequest(bytes32 requestOwnerEntity, bytes32 requestId) external;
}

using RNGSystemLib for RNGSystemType global;
using RNGSystemLib for CallWrapper global;
using RNGSystemLib for RootCallWrapper global;
