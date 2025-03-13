// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Script } from "forge-std/Script.sol";
import { VmSafe } from "forge-std/Vm.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { Idx_AffixPrototype_ExclusiveGroup } from "../src/namespaces/affix/codegen/idxs/Idx_AffixPrototype_ExclusiveGroup.sol";
import { UniqueIdx_AffixPrototype_TierName } from "../src/namespaces/affix/codegen/idxs/UniqueIdx_AffixPrototype_TierName.sol";

import { LibInitStatmod } from "../src/namespaces/root/init/LibInitStatmod.sol";
import { LibInitSkill } from "../src/namespaces/root/init/LibInitSkill.sol";
import { LibInitGuise } from "../src/namespaces/root/init/LibInitGuise.sol";
import { LibInitEquipmentAffix } from "../src/namespaces/root/init/LibInitEquipmentAffix.sol";
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

  Idx_AffixPrototype_ExclusiveGroup.register();
  UniqueIdx_AffixPrototype_TierName.register();

  LibInitStatmod.init();
  LibInitSkill.init();
  LibInitGuise.init();
  LibInitEquipmentAffix.init();
  LibInitWheel.init();
  LibInitERC721.init();

  vm.stopBroadcast();
}

contract PostDeploy is Script {
  function run(address worldAddress) external {
    runPostDeployInitializers(vm, worldAddress);
  }
}
