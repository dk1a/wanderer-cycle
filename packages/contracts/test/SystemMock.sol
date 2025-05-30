// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";

import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { ResourceId, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { FunctionSelectors } from "@latticexyz/world/src/codegen/tables/FunctionSelectors.sol";

function createSystemMock(address worldAddress, ResourceId systemId) returns (address mockForwarderAddress) {
  IBaseWorld world = IBaseWorld(worldAddress);

  ResourceId namespaceId = WorldResourceIdInstance.getNamespaceId(systemId);
  if (!ResourceIds.getExists(namespaceId)) {
    world.registerNamespace(namespaceId);
  }

  SystemMock _systemMock = new SystemMock();
  world.registerSystem(systemId, _systemMock, true);

  SystemMockForwarder _systemMockForwarder = new SystemMockForwarder(worldAddress, systemId);
  return address(_systemMockForwarder);
}

/**
 * A system that calls another system, forwarding calldata, to simulate simple system-to-system calls
 */
contract SystemMock is System {
  function forwardCall(ResourceId systemId, bytes memory callData) external {
    IBaseWorld world = IBaseWorld(_world());
    bytes memory returnData = world.call(systemId, callData);

    // If the call was successful, return the return data
    assembly {
      return(add(returnData, 0x20), mload(returnData))
    }
  }
}

/**
 * Forwarder is called the same way as world, e.g. `IWorld(forwarderAddress).combat__actPVERound(...)`
 * This helps simulate simple system-to-system calls without needing lots of mock contracts
 *
 * 0. Forwarder contract is not part of the world, and expects the SystemMock to be a public system
 * 1. Forwarder receives world selector + encoded args (e.g. `combat__actPVERound` + args)
 * 2. Forwarder converts it to systemId + system calldata (e.g. "combat:CombatSystem", actPVERound selector + encoded args)
 * 3. Forwarder calls SystemMock with the systemId and calldata (via world)
 * 4. SystemMock calls the system with the systemId and calldata (this is the first system-to-system call)
 * 5. Both SystemMock and its forwarder return what the called system does, which can have any format, so assembly is used
 */
contract SystemMockForwarder {
  error SystemMockForwarder_FunctionSelectorNotFound(bytes4 functionSelector);

  address internal worldAddress;
  ResourceId internal mockSystemId;

  constructor(address _worldAddress, ResourceId _mockSystemId) {
    worldAddress = _worldAddress;
    mockSystemId = _mockSystemId;

    StoreSwitch.setStoreAddress(worldAddress);
  }

  fallback() external payable {
    (ResourceId systemId, bytes4 systemFunctionSelector) = FunctionSelectors.get(msg.sig);

    if (ResourceId.unwrap(systemId) == 0) revert SystemMockForwarder_FunctionSelectorNotFound(msg.sig);

    // Replace function selector in the calldata with the system function selector
    bytes memory callData = Bytes.setBytes4(msg.data, 0, systemFunctionSelector);

    // Call the mock system
    bytes memory returnData = IBaseWorld(worldAddress).call(
      mockSystemId,
      abi.encodeWithSelector(SystemMock.forwardCall.selector, systemId, callData)
    );

    // If the call was successful, return the return data
    assembly {
      return(add(returnData, 0x20), mload(returnData))
    }
  }
}
