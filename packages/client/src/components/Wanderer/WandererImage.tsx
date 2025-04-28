import { useEffect, useState } from "react";
import { Hex, hexToBigInt } from "viem";
import { usePublicClient } from "wagmi";

import { getRecord } from "@latticexyz/stash/internal";
import { resourceToHex } from "@latticexyz/common";

import ERC721SystemAbi from "contracts/out/ERC721System.sol/ERC721System.abi.json";

import { mudTables, useStashCustom } from "../../mud/stash";
import { chainId } from "../../common";

// TODO contracts don't export ERC721Namespaces, which are solidity-only
const wandererNamespaceId = resourceToHex({
  type: "namespace",
  namespace: "Wanderer",
  name: "",
});

export function WandererImage({ entity }: { readonly entity: Hex }) {
  const publicClient = usePublicClient({ chainId });
  const [img, setImg] = useState("");

  const registry = useStashCustom((state) =>
    getRecord({
      state,
      table: mudTables["erc721-puppet__ERC721Registry"],
      key: { namespaceId: wandererNamespaceId },
    }),
  );

  useEffect(() => {
    (async () => {
      if (registry === undefined || publicClient === undefined) return;

      const tokenId = hexToBigInt(entity);
      const uri = await publicClient.readContract({
        address: registry.tokenAddress,
        abi: ERC721SystemAbi,
        functionName: "tokenURI",
        args: [tokenId],
      });

      const json = await (await fetch(uri)).json();
      setImg(json.image);
    })();
  }, [publicClient, registry, entity]);

  return <object data={img} className="w-64 h-64" />;
}
