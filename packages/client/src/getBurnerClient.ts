import {
  Account,
  Chain,
  Client,
  createWalletClient,
  fallback,
  http,
  Transport,
  webSocket,
} from "viem";
import {
  createBurnerAccount,
  getBurnerPrivateKey,
  transportObserver,
} from "@latticexyz/common";
import { getChain } from "./wagmiConfig";

const burnerAccount = createBurnerAccount(getBurnerPrivateKey());

/*
export function useBurnerClient(): Client<Transport, Chain, Account> {
  const client = useClient({ chainId });
  return useMemo(() => {
    if (!client) throw new Error("Client not ready.");
    return getBurnerClient({
      publicClient: client,
    });
  }, [client]);
}
*/

export function getBurnerClient(): Client<Transport, Chain, Account> {
  return createWalletClient({
    chain: getChain(),
    transport: transportObserver(fallback([webSocket(), http()])),
    pollingInterval: 1000,
    account: burnerAccount,
  });
  /*.extend(
    callFrom({
      worldAddress: getWorldAddress(),
      delegatorAddress: burnerAccount.address,
      publicClient,
    })
  );*/
}
