import type { SetupContractConfig } from "@latticexyz/std-client";
import { getBurnerWallet } from "./getBurnerWallet";

const params = new URLSearchParams(window.location.search);

export const config: SetupContractConfig & { faucetServiceUrl?: string } = {
  clock: {
    period: 1000,
    initialTime: 0,
    syncInterval: 5000,
  },
  provider: {
    jsonRpcUrl: params.get("rpc") ?? "https://follower.testnet-chain.linfra.xyz",
    wsRpcUrl: params.get("wsRpc") ?? "wss://follower.testnet-chain.linfra.xyz",
    chainId: Number(params.get("chainId")) || 4242,
  },
  privateKey: getBurnerWallet().privateKey,
  chainId: Number(params.get("chainId")) || 4242,
  snapshotServiceUrl: params.get("snapshot") ?? "https://ecs-snapshot.testnet-mud-services.linfra.xyz",
  faucetServiceUrl: params.get("faucet") ?? "https://faucet.testnet-mud-services.linfra.xyz",
  initialBlockNumber: Number(params.get("initialBlockNumber")) || 9045311,
  worldAddress: params.get("worldAddress") ?? "0xCceC5dFc845AdF8C4a1468A29E504059383503aF",
  devMode: params.get("dev") === "true",
};
