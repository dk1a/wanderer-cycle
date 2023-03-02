import { useEffect, useState } from "react";
import { useMUD } from "../MUDContext";

export function useBlockNumber() {
  const {
    network: { blockNumber$ },
  } = useMUD();
  const [blockNumber, setBlockNumber] = useState<number>();

  useEffect(() => {
    const subscription = blockNumber$.subscribe((newBlockNumber) => setBlockNumber(newBlockNumber));
    return () => subscription.unsubscribe();
  }, [blockNumber$]);

  return blockNumber;
}
