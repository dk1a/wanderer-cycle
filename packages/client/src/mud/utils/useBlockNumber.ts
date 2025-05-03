import { useEffect, useState } from "react";
import { useMUD } from "../../MUDContext";

export function useBlockNumber() {
  const { network } = useMUD();
  const latestBlock = network.latestBlock$;
  const [blockNumber, setBlockNumber] = useState<number>();

  useEffect(() => {
    const subscription = latestBlock.subscribe((block) => {
      if (typeof block === "number") {
        setBlockNumber(block);
      } else if (typeof block === "object" && block?.number !== undefined) {
        setBlockNumber(Number(block.number));
      }
    });

    return () => subscription.unsubscribe();
  }, [latestBlock]);

  return blockNumber;
}
