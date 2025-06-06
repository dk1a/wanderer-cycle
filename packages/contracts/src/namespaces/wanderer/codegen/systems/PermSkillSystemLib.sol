// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { PermSkillSystem } from "../../PermSkillSystem.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";
import { IWorldCall } from "@latticexyz/world/src/IWorldKernel.sol";
import { SystemCall } from "@latticexyz/world/src/SystemCall.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

type PermSkillSystemType is bytes32;

// equivalent to WorldResourceIdLib.encode({ typeId: RESOURCE_SYSTEM, namespace: "wanderer", name: "PermSkillSystem" }))
PermSkillSystemType constant permSkillSystem = PermSkillSystemType.wrap(
  0x737977616e64657265720000000000005065726d536b696c6c53797374656d00
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
 * @title PermSkillSystemLib
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This library is automatically generated from the corresponding system contract. Do not edit manually.
 */
library PermSkillSystemLib {
  error PermSkillSystemLib_CallingFromRootSystem();
  error PermSkillSystem_NoPreviousCycle();
  error PermSkillSystem_SkillNotLearnedInLastCompletedCycle(bytes32 prevCycleEntity);
  error PermSkillSystem_NotEnoughIdentity();

  function permSkill(PermSkillSystemType self, bytes32 wandererEntity, bytes32 skillEntity) internal {
    return CallWrapper(self.toResourceId(), address(0)).permSkill(wandererEntity, skillEntity);
  }

  function permSkill(CallWrapper memory self, bytes32 wandererEntity, bytes32 skillEntity) internal {
    // if the contract calling this function is a root system, it should use `callAsRoot`
    if (address(_world()) == address(this)) revert PermSkillSystemLib_CallingFromRootSystem();

    bytes memory systemCall = abi.encodeCall(_permSkill_bytes32_bytes32.permSkill, (wandererEntity, skillEntity));
    self.from == address(0)
      ? _world().call(self.systemId, systemCall)
      : _world().callFrom(self.from, self.systemId, systemCall);
  }

  function permSkill(RootCallWrapper memory self, bytes32 wandererEntity, bytes32 skillEntity) internal {
    bytes memory systemCall = abi.encodeCall(_permSkill_bytes32_bytes32.permSkill, (wandererEntity, skillEntity));
    SystemCall.callWithHooksOrRevert(self.from, self.systemId, systemCall, msg.value);
  }

  function callFrom(PermSkillSystemType self, address from) internal pure returns (CallWrapper memory) {
    return CallWrapper(self.toResourceId(), from);
  }

  function callAsRoot(PermSkillSystemType self) internal view returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), WorldContextConsumerLib._msgSender());
  }

  function callAsRootFrom(PermSkillSystemType self, address from) internal pure returns (RootCallWrapper memory) {
    return RootCallWrapper(self.toResourceId(), from);
  }

  function toResourceId(PermSkillSystemType self) internal pure returns (ResourceId) {
    return ResourceId.wrap(PermSkillSystemType.unwrap(self));
  }

  function fromResourceId(ResourceId resourceId) internal pure returns (PermSkillSystemType) {
    return PermSkillSystemType.wrap(resourceId.unwrap());
  }

  function getAddress(PermSkillSystemType self) internal view returns (address) {
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

interface _permSkill_bytes32_bytes32 {
  function permSkill(bytes32 wandererEntity, bytes32 skillEntity) external;
}

using PermSkillSystemLib for PermSkillSystemType global;
using PermSkillSystemLib for CallWrapper global;
using PermSkillSystemLib for RootCallWrapper global;
