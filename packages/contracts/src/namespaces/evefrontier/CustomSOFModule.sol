// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { worldRegistrationSystem } from "@latticexyz/world/src/codegen/experimental/systems/WorldRegistrationSystemLib.sol";
import { moduleInstallationSystem } from "@latticexyz/world/src/codegen/experimental/systems/ModuleInstallationSystemLib.sol";
import { UNLIMITED_DELEGATION } from "@latticexyz/world/src/constants.sol";

import { SOFModule } from "@eveworld/smart-object-framework-v2/src/module/SOFModule.sol";
import { delegateInstallSOFModule } from "@eveworld/smart-object-framework-v2/src/module/delegateInstallSOFModule.sol";
import { EntitySystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/systems/EntitySystemLib.sol";
import { RoleManagementSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/systems/RoleManagementSystemLib.sol";
import { TagSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/systems/TagSystemLib.sol";
import { SOFAccessSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/sofaccess/codegen/systems/SOFAccessSystemLib.sol";

import { AccessConfigSystem, accessConfigSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/systems/AccessConfigSystemLib.sol";
import { CallAccessSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/systems/CallAccessSystemLib.sol";
import { EntitySystem, entitySystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/systems/EntitySystemLib.sol";
import { RoleManagementSystem, roleManagementSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/systems/RoleManagementSystemLib.sol";
import { TagSystem, tagSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/systems/TagSystemLib.sol";
import { SOFAccessSystem, sOFAccessSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/sofaccess/codegen/systems/SOFAccessSystemLib.sol";

import { ISOFAccessSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/sofaccess/interfaces/ISOFAccessSystem.sol";

import { EntitySystem as CustomEntitySystem } from "./EntitySystem.sol";

function delegateInstallCustomSOFModule() {
  delegateInstallSOFModule(
    new CustomSOFModule(
      new AccessConfigSystem(),
      new CallAccessSystem(),
      EntitySystem(address(new CustomEntitySystem())),
      new RoleManagementSystem(),
      new TagSystem(),
      new SOFAccessSystem()
    )
  );
}

contract CustomSOFModule is SOFModule {
  constructor(
    AccessConfigSystem _accessConfigSystem,
    CallAccessSystem _callAccessSystem,
    EntitySystem _entitySystem,
    RoleManagementSystem _roleManagementSystem,
    TagSystem _tagSystem,
    SOFAccessSystem _sOFAccessSystem
  )
    SOFModule(
      _accessConfigSystem,
      _callAccessSystem,
      _entitySystem,
      _roleManagementSystem,
      _tagSystem,
      _sOFAccessSystem
    )
  {}

  function install(bytes memory encodedArgs) public virtual override {
    super.install(encodedArgs);

    // Configure the altered methods of EntitySystem

    // EntitySystem.sol access configurations
    // set allowClassScopedSystemOrDirectAccessRole for instantiate
    accessConfigSystem.callFrom(_msgSender()).configureAccess(
      entitySystem.toResourceId(),
      CustomEntitySystem.instantiate.selector,
      sOFAccessSystem.toResourceId(),
      ISOFAccessSystem.allowClassScopedSystemOrDirectClassAccessRole.selector
    );
    // set allowClassScopedSystemOrDirectAccessRole for addToScope
    accessConfigSystem.callFrom(_msgSender()).configureAccess(
      entitySystem.toResourceId(),
      CustomEntitySystem.addToScope.selector,
      sOFAccessSystem.toResourceId(),
      ISOFAccessSystem.allowClassScopedSystemOrDirectClassAccessRole.selector
    );

    // EntitySystem.sol toggle access enforcement on
    accessConfigSystem.callFrom(_msgSender()).setAccessEnforcement(
      entitySystem.toResourceId(),
      CustomEntitySystem.instantiate.selector,
      true
    );
    accessConfigSystem.callFrom(_msgSender()).setAccessEnforcement(
      entitySystem.toResourceId(),
      CustomEntitySystem.addToScope.selector,
      true
    );
  }
}
