// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { entitySystem } from "../src/namespaces/evefrontier/codegen/systems/EntitySystemLib.sol";
import { LibSOFClass } from "../src/namespaces/common/LibSOFClass.sol";
import { GenericDurationData } from "../src/namespaces/duration/codegen/tables/GenericDuration.sol";

import { runPostDeploy } from "../script/PostDeploy.s.sol";

import { createSystemMock } from "./SystemMock.sol";

abstract contract BaseTest is MudTest {
  IWorld world;

  address deployer;
  address alice = address(bytes20(keccak256("alice")));
  address bob = address(bytes20(keccak256("bob")));

  bytes32 emptyClassId;
  bytes32 emptyEntity;

  ResourceId scopedSystemId;
  IWorld scopedSystemMock;
  ResourceId emptySystemId;
  IWorld emptySystemMock;

  function setUp() public virtual override {
    super.setUp();

    // See the comment for runPostDeploy
    // It is called here directly for optimization
    // This relies on `script` in `foundry.toml` skipping PostDeploy when deploying locally
    runPostDeploy(vm, worldAddress, true);

    world = IWorld(worldAddress);

    deployer = vm.addr(vm.envUint("PRIVATE_KEY"));

    // Create system mocks for system-to-system call tests
    (scopedSystemId, scopedSystemMock) = _createSystemMock("test_scoped", "scopedSystem");
    (emptySystemId, emptySystemMock) = _createSystemMock("test_empty", "emptySystem");

    // Add scopedSystemId to the scope of test classes
    _addToScope("test", scopedSystemId);
    _addToScope("test2", scopedSystemId);
    // Instantiate common test entities
    emptyClassId = LibSOFClass.getClassId("empty");
    vm.startPrank(deployer);
    emptyEntity = LibSOFClass.instantiate("empty", deployer);
    vm.stopPrank();

    address testContractAddress = address(this);
    // root
    _grantAccess("", testContractAddress);
    // all the other namespaces (allows setting tables directly within tests)
    _grantAccess("affix", testContractAddress);
    _grantAccess("charstat", testContractAddress);
    _grantAccess("combat", testContractAddress);
    _grantAccess("common", testContractAddress);
    _grantAccess("cycle", testContractAddress);
    _grantAccess("duration", testContractAddress);
    _grantAccess("effect", testContractAddress);
    _grantAccess("equipment", testContractAddress);
    _grantAccess("loot", testContractAddress);
    _grantAccess("map", testContractAddress);
    _grantAccess("rng", testContractAddress);
    _grantAccess("skill", testContractAddress);
    _grantAccess("statmod", testContractAddress);
    _grantAccess("time", testContractAddress);
    _grantAccess("wheel", testContractAddress);
  }

  function _createSystemMock(
    bytes14 namespace,
    bytes16 systemName
  ) internal returns (ResourceId systemId, IWorld mock) {
    vm.startPrank(deployer);

    systemId = WorldResourceIdLib.encode(RESOURCE_SYSTEM, namespace, systemName);
    mock = IWorld(createSystemMock(worldAddress, systemId));

    vm.stopPrank();
  }

  function _addToScope(string memory className, ResourceId systemId) internal {
    bytes32 classId = LibSOFClass.getClassId(className);
    ResourceId[] memory systemIds = new ResourceId[](1);
    systemIds[0] = systemId;

    vm.startPrank(deployer);
    entitySystem.addToScope(uint256(classId), systemIds);
    vm.stopPrank();
  }

  function _grantAccess(bytes14 namespace, address grantee) internal {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.broadcast(deployerPrivateKey);
    world.grantAccess(WorldResourceIdLib.encodeNamespace(namespace), grantee);
  }

  function assertEq(GenericDurationData memory a, GenericDurationData memory b, string memory err) internal pure {
    string memory timeIdReadableInequality = string.concat(
      string(bytes.concat(a.timeId)),
      " != ",
      string(bytes.concat(b.timeId)),
      " "
    );
    assertEq(a.timeId, b.timeId, string.concat("timeId ", timeIdReadableInequality, err));
    assertEq(a.timeValue, b.timeValue, string.concat("timeValue ", err));
  }
}
