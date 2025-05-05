import { useClient } from "wagmi";
import {
  Account,
  Chain,
  Client,
  GetContractReturnType,
  Transport,
  getContract,
} from "viem";
import { useQuery } from "@tanstack/react-query";
import { observer } from "@latticexyz/explorer/observer";
import worldAbi from "contracts/out/IWorld.sol/IWorld.abi.json";
import { chainId, getWorldAddress } from "../common";
import { getBurnerClient } from "../getBurnerClient";
import { useMemo } from "react";

export type WorldContract = GetContractReturnType<
  typeof worldAbi,
  {
    public: Client<Transport, Chain>;
    wallet: Client<Transport, Chain, Account>;
  }
>;

export function useWorldContract(): WorldContract | undefined {
  const client = useClient({ chainId });
  const burnerClient = useMemo(() => getBurnerClient(), []);

  const { data: worldContract } = useQuery({
    queryKey: ["worldContract", client?.uid, burnerClient?.uid],
    queryFn: () => {
      if (!client || !burnerClient) {
        throw new Error("Not connected.");
      }

      return getContract({
        abi: worldAbi,
        address: getWorldAddress(),
        client: {
          public: client,
          wallet: burnerClient.extend(observer()),
        },
      });
    },
    staleTime: Infinity,
    refetchOnMount: false,
    refetchOnReconnect: false,
    refetchOnWindowFocus: false,
  });

  return worldContract;
}
