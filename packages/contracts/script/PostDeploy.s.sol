// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Script } from "forge-std/Script.sol";
import { VmSafe } from "forge-std/Vm.sol";
import { console } from "forge-std/console.sol";

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ROOT_NAMESPACE_ID } from "@latticexyz/world/src/constants.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { timeSystem } from "../src/namespaces/time/codegen/systems/TimeSystemLib.sol";
import { initCycleSystem } from "../src/namespaces/cycle/codegen/systems/InitCycleSystemLib.sol";
import { randomEquipmentSystem } from "../src/namespaces/loot/codegen/systems/RandomEquipmentSystemLib.sol";
import { randomMapSystem } from "../src/namespaces/loot/codegen/systems/RandomMapSystemLib.sol";
import { effectSystem } from "../src/namespaces/effect/codegen/systems/EffectSystemLib.sol";

import { batchRegisterIdxs as root_batchRegisterIdxs } from "../src/namespaces/root/codegen/batchRegisterIdxs.sol";
import { batchRegisterIdxs as skill_batchRegisterIdxs } from "../src/namespaces/skill/codegen/batchRegisterIdxs.sol";
import { batchRegisterIdxs as affix_batchRegisterIdxs } from "../src/namespaces/affix/codegen/batchRegisterIdxs.sol";
import { batchRegisterIdxs as equipment_batchRegisterIdxs } from "../src/namespaces/equipment/codegen/batchRegisterIdxs.sol";
import { batchRegisterIdxs as wheel_batchRegisterIdxs } from "../src/namespaces/wheel/codegen/batchRegisterIdxs.sol";

import { LibInitStatmod } from "../src/namespaces/root/init/LibInitStatmod.sol";
import { LibInitSkill } from "../src/namespaces/root/init/LibInitSkill.sol";
import { LibInitGuise } from "../src/namespaces/root/init/LibInitGuise.sol";
import { LibInitEquipmentAffix } from "../src/namespaces/root/init/LibInitEquipmentAffix.sol";
import { LibInitMapAffix } from "../src/namespaces/root/init/LibInitMapAffix.sol";
import { LibInitMapsGlobal } from "../src/namespaces/root/init/LibInitMapsGlobal.sol";
import { LibInitMapsBoss } from "../src/namespaces/root/init/LibInitMapsBoss.sol";
import { LibInitWheel } from "../src/namespaces/wheel/LibInitWheel.sol";
import { LibInitERC721 } from "../src/namespaces/root/init/LibInitERC721.sol";

import { EffectDuration } from "../src/namespaces/effect/codegen/tables/EffectDuration.sol";
import { SkillCooldown } from "../src/namespaces/skill/codegen/tables/SkillCooldown.sol";
import { StatmodValue } from "../src/namespaces/statmod/codegen/tables/StatmodValue.sol";
import { Affix } from "../src/namespaces/affix/codegen/tables/Affix.sol";
import { EquipmentTypeComponent } from "../src/namespaces/equipment/codegen/tables/EquipmentTypeComponent.sol";

// Init txs are large, especially affixes
// Separating the script body allows it to be run directly within tests much faster, skipping lengthy broadcasts
// In testnet/prod this would be a one-off long expensive deployment
// TODO consider optimization where possible, some of it can be done offchain via ffi for example
function runPostDeployInitializers(VmSafe vm, address worldAddress) {
  // Specify a store so that you can use tables directly in PostDeploy
  StoreSwitch.setStoreAddress(worldAddress);

  // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
  uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

  // Start broadcasting transactions from the deployer account
  vm.startBroadcast(deployerPrivateKey);

  root_batchRegisterIdxs();
  skill_batchRegisterIdxs();
  affix_batchRegisterIdxs();
  equipment_batchRegisterIdxs();
  wheel_batchRegisterIdxs();

  LibInitStatmod.init();
  LibInitSkill.init();
  LibInitGuise.init();
  LibInitEquipmentAffix.init();
  LibInitMapAffix.init();
  LibInitMapsGlobal.init();
  LibInitMapsBoss.init();
  LibInitWheel.init();
  LibInitERC721.init();

  address timeSystemAddress = timeSystem.getAddress();
  IWorld(worldAddress).grantAccess(EffectDuration._tableId, timeSystemAddress);
  IWorld(worldAddress).grantAccess(SkillCooldown._tableId, timeSystemAddress);

  // TODO I don't like these tables being used directly by another namespace - system wrap them, or change tables
  IWorld(worldAddress).grantAccess(Affix._tableId, randomEquipmentSystem.getAddress());
  IWorld(worldAddress).grantAccess(EquipmentTypeComponent._tableId, randomEquipmentSystem.getAddress());
  IWorld(worldAddress).grantAccess(Affix._tableId, randomMapSystem.getAddress());

  // TODO this feels less wrong, not sure; should statmod have a system?
  IWorld(worldAddress).grantAccess(StatmodValue._tableId, effectSystem.getAddress());

  // TODO reconsider this, along with `.callAsRootFrom(address(this))` instances
  IWorld(worldAddress).grantAccess(ROOT_NAMESPACE_ID, worldAddress);
  IWorld(worldAddress).grantAccess(initCycleSystem.toResourceId(), worldAddress);

  vm.stopBroadcast();
}

contract PostDeploy is Script {
  function run(address worldAddress) external {
    runPostDeployInitializers(vm, worldAddress);
  }
}
