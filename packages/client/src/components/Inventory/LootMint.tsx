import { useCallback, useMemo, useState, ChangeEvent } from "react";
import { BigNumber } from "ethers";
import { useGetLootState } from "../../hooks/queries/useGetLootState";
import { useMintIdentifiedLoot } from "../../hooks/mutations/useMintIdentifiedLoot";

import CustomButton from "../UI/CustomButton/CustomButton";

const DEFAULT_BATCH_SIZE = 16;

export default function LootMint({ account, name }: { account: string; name: string }) {
  const lootState = useGetLootState(account);

  const [batchSize, setBatchSize] = useState<number>();
  const onBatchSizeChange = useCallback((e: ChangeEvent<HTMLInputElement>) => {
    const batchSize = parseInt(e.target.value);
    if (!isNaN(batchSize) && isFinite(batchSize)) {
      setBatchSize(batchSize);
    } else {
      setBatchSize(undefined);
    }
  }, []);

  const availableSize = useMemo(() => {
    if (!lootState.data) return;
    const totalSize = lootState.data.amounts.reduce((acc, val) => acc.add(val), BigNumber.from(0));
    return totalSize.sub(lootState.data.iterationOffset);
  }, [lootState]);

  const batchSizeAuto = useMemo(() => {
    if (batchSize !== undefined) return batchSize;
    if (availableSize === undefined) return;
    return availableSize.gt(DEFAULT_BATCH_SIZE) ? DEFAULT_BATCH_SIZE : availableSize.toNumber();
  }, [batchSize, availableSize]);

  const isMintAvailable = useMemo(() => {
    return !!lootState.data?.canMint;
  }, [lootState]);

  const mintIdentifiedLoot = useMintIdentifiedLoot(account, batchSizeAuto, isMintAvailable);

  const mintCallback = useCallback(() => {
    mintIdentifiedLoot?.writer.write?.();
    setBatchSize(undefined);
  }, [mintIdentifiedLoot]);

  return (
    <section>
      <h4 className="text-dark-comment">{`// ======== LootMint ${name} ========`}</h4>
      <div className="flex items-center space-x-4">
        <div>
          <span className="text-dark-key mr-2">availableSize:</span>
          {availableSize ? (
            <span className="text-dark-number">{availableSize.toString()}</span>
          ) : (
            <span>undefined</span>
          )}
        </div>

        <div>
          <span className="text-dark-key">batchSize: </span>
          <input
            type="number"
            className="bg-transparent text-dark-number w-12 rounded border border-dark-400"
            value={batchSize === undefined ? "" : batchSize}
            disabled={mintIdentifiedLoot.writer.isLoading}
            placeholder={batchSizeAuto?.toString()}
            onChange={onBatchSizeChange}
          />
        </div>

        <CustomButton disabled={mintIdentifiedLoot.isBusy} onClick={mintCallback}>
          mint
        </CustomButton>

        {!mintIdentifiedLoot.writer.write && <div>..preparing..</div>}
        {mintIdentifiedLoot.writer.isLoading && <div>..minting..</div>}
      </div>
    </section>
  );
}
