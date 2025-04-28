import { Chain, http, webSocket } from "viem";
import { anvil } from "viem/chains";
import { createWagmiConfig } from "@latticexyz/entrykit/internal";
import { rhodolite, garnet, redstone } from "@latticexyz/common/chains";
import { chainId } from "./common";

export const chains = [
  redstone,
  garnet,
  rhodolite,
  {
    ...anvil,
    contracts: {
      ...anvil.contracts,
      paymaster: {
        address: "0xf03E61E7421c43D9068Ca562882E98d1be0a6b6e",
      },
    },
    blockExplorers: {
      default: {} as never,
      worldsExplorer: {
        name: "MUD Worlds Explorer",
        url: "http://localhost:13690/anvil/worlds",
      },
    },
    fees: {
      async estimateFeesPerGas({ type }) {
        if (type === "legacy") return { gasPrice: 0n };
        return {
          maxFeePerGas: 0n,
          maxPriorityFeePerGas: 0n,
        };
      },
    },
  },
] as const satisfies Chain[];

export function getChain(): Chain {
  const chain = chains.find((c) => c.id === chainId);
  if (!chain) {
    throw new Error(`No chain configured for chain ID ${chainId}.`);
  }
  return chain;
}

export const transports = {
  [anvil.id]: webSocket(),
  [garnet.id]: http(),
  [rhodolite.id]: http(),
  [redstone.id]: http(),
} as const;

export const wagmiConfig = createWagmiConfig({
  chainId,
  walletConnectProjectId: "3a6d05ca7e9c89116deef3d2c365651c",
  appName: document.title,
  chains,
  transports,
  pollingInterval: {
    [anvil.id]: 2000,
    [garnet.id]: 2000,
    [rhodolite.id]: 2000,
    [redstone.id]: 2000,
  },
});
