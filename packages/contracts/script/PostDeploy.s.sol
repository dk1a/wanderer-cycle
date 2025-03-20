// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Script } from "forge-std/Script.sol";
import { VmSafe } from "forge-std/Vm.sol";
import { console } from "forge-std/console.sol";

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ROOT_NAMESPACE_ID } from "@latticexyz/world/src/constants.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { batchRegisterIdxs as root_batchRegisterIdxs } from "../src/namespaces/root/codegen/batchRegisterIdxs.sol";
import { batchRegisterIdxs as affix_batchRegisterIdxs } from "../src/namespaces/affix/codegen/batchRegisterIdxs.sol";

import { LibInitStatmod } from "../src/namespaces/root/init/LibInitStatmod.sol";
import { LibInitSkill } from "../src/namespaces/root/init/LibInitSkill.sol";
import { LibInitGuise } from "../src/namespaces/root/init/LibInitGuise.sol";
import { LibInitEquipmentAffix } from "../src/namespaces/root/init/LibInitEquipmentAffix.sol";
import { LibInitMapAffix } from "../src/namespaces/root/init/LibInitMapAffix.sol";
import { LibInitMapsGlobal } from "../src/namespaces/root/init/LibInitMapsGlobal.sol";
import { LibInitMapsBoss } from "../src/namespaces/root/init/LibInitMapsBoss.sol";
import { LibInitWheel } from "../src/namespaces/root/init/LibInitWheel.sol";
import { LibInitERC721 } from "../src/namespaces/root/init/LibInitERC721.sol";

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
  affix_batchRegisterIdxs();

  LibInitStatmod.init();
  LibInitSkill.init();
  LibInitGuise.init();
  LibInitEquipmentAffix.init();
  LibInitMapAffix.init();
  LibInitMapsGlobal.init();
  LibInitMapsBoss.init();
  LibInitWheel.init();
  LibInitERC721.init();

  // TODO reconsider this, along with `.callAsRootFrom(address(this))` instances
  IWorld(worldAddress).grantAccess(ROOT_NAMESPACE_ID, worldAddress);

  vm.stopBroadcast();
}

contract PostDeploy is Script {
  function run(address worldAddress) external {
    runPostDeployInitializers(vm, worldAddress);
  }
}
