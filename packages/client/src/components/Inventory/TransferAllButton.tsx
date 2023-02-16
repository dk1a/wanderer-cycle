import { useMemo } from "react";
import { useWalletsLootContext } from "../../contexts/WalletsLootContext";
import { useSafeBatchTransferFrom } from "../../hooks/mutations/useSafeBatchTransferFrom";
import MethodButton from "../MethodButton";

export default function TransferAllButton({ toAccount, name }: { toAccount: string; name: string }) {
  const { allLootList } = useWalletsLootContext();

  const listForTransfer = useMemo(() => {
    return allLootList?.filter(({ account }) => account !== toAccount);
  }, [toAccount, allLootList]);

  const fromAccounts = useMemo(() => {
    return [...new Set(listForTransfer?.map(({ account }) => account))];
  }, [listForTransfer]);

  const safeBatchTransferFrom = useSafeBatchTransferFrom();

  const transferAllButton = useMemo(() => {
    const isAvailable = !!listForTransfer && listForTransfer.length > 0;
    const isDisabled = safeBatchTransferFrom.isLoading;
    return {
      isAvailable,
      isDisabled,
      callback: () => {
        if (!isAvailable || isDisabled) return;
        for (const fromAccount of fromAccounts) {
          const accountLoot = listForTransfer.filter(({ account }) => account === fromAccount);
          const ids = accountLoot.map(({ tokenId }) => tokenId);
          const amounts = accountLoot.map(({ balance }) => balance);
          safeBatchTransferFrom.write({ recklesslySetUnpreparedArgs: [fromAccount, toAccount, ids, amounts, "0x"] });
        }
      },
    };
  }, [listForTransfer, toAccount, fromAccounts, safeBatchTransferFrom]);

  return (
    <div>
      {transferAllButton.isAvailable && (
        <MethodButton
          name="transferAllTo"
          args={[name]}
          disabled={transferAllButton.isDisabled}
          onClick={transferAllButton.callback}
        />
      )}
    </div>
  );
}
