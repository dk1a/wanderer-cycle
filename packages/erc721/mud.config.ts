import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  namespace: "erc721-puppet",
  codegen: {
    generateSystemLibraries: true,
  },
  systems: {
    RegisterERC721System: {
      deploy: {
        disabled: true,
        registerWorldFunctions: false,
      },
    },
  },
  modules: [
    {
      artifactPath: "@latticexyz/world-modules/out/StandardDelegationsModule.sol/StandardDelegationsModule.json",
      root: true,
      args: [],
    },
    {
      artifactPath: "@latticexyz/world-modules/out/PuppetModule.sol/PuppetModule.json",
      root: true,
      args: [],
    },
    {
      artifactPath: "./out/ERC721Module.sol/ERC721Module.json",
      root: false,
      args: [],
    },
  ],
});
