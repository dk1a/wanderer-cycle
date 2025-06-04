// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";
import { BaseTest } from "./BaseTest.t.sol";

import { commonSystem } from "../src/namespaces/common/codegen/systems/CommonSystemLib.sol";
import { LibSOFAccess } from "../src/namespaces/evefrontier/LibSOFAccess.sol";
import { LibSOFClass } from "../src/namespaces/common/LibSOFClass.sol";
import { Name, OwnedBy } from "../src/namespaces/common/codegen/index.sol";

contract CommonSystemTest is BaseTest {
  bytes32 entity;
  bytes32 entity2;

  function setUp() public virtual override {
    super.setUp();

    _addToScope("test", commonSystem.toResourceId());

    vm.startPrank(deployer);

    entity = LibSOFClass.instantiate("test", alice);
    entity = LibSOFClass.instantiate("test2", alice);

    vm.stopPrank();
  }

  function testRevertUnscoped() public {
    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, entity, emptySystemId)
    );
    emptySystemMock.common__setName(entity, "test entity name");

    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, entity, emptySystemId)
    );
    emptySystemMock.common__setOwnedBy(entity, entity2);
  }

  function testRevertAccessDenied() public {
    vm.startPrank(bob);

    vm.expectRevert(abi.encodeWithSelector(LibSOFAccess.SOFAccess_AccessDenied.selector, entity, bob));
    commonSystem.setName(entity, "test entity name");

    vm.expectRevert(abi.encodeWithSelector(LibSOFAccess.SOFAccess_AccessDenied.selector, entity, bob));
    commonSystem.setOwnedBy(entity, entity2);

    vm.stopPrank();
  }

  function testScopedSet() public {
    scopedSystemMock.common__setName(entity, "test entity name");
    assertEq(Name.get(entity), "test entity name");

    scopedSystemMock.common__setOwnedBy(entity, entity2);
    assertEq(OwnedBy.get(entity), entity2);
  }

  function testDirectSet() public {
    vm.startPrank(alice);

    commonSystem.setName(entity, "test entity name");
    assertEq(Name.get(entity), "test entity name");

    commonSystem.setOwnedBy(entity, entity2);
    assertEq(OwnedBy.get(entity), entity2);

    vm.stopPrank();
  }
}
