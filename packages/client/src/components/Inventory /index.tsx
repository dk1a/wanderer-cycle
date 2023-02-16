import { useMemo, useState } from "react";
import { useWalletsLootContext } from "../../contexts/WalletsLootContext";
import { useUrisJson } from "../../hooks/uri/useUriJson";
import AccountsHeader from "./AccountsHeader";
import LootList from "./LootList";
import LootMint from "./LootMint";

type Option = { value: string; label: string } | null;

export default function Inventory() {
  const { accounts, lootState, shownLootList } = useWalletsLootContext();
  const [modSort, setModSort] = useState<Option>(null);

  const lootIds = useMemo(() => shownLootList?.map(({ tokenId }) => tokenId) ?? [], [shownLootList]);
  const jsonQueries = useUrisJson(lootIds);

  const sortedLootList = useMemo(() => {
    if (!modSort) return shownLootList;
    const lootListWithModSum = shownLootList?.map((tokenData, index) => {
      const modSum =
        jsonQueries[index].data?.affixes?.reduce(
          (acc, cur) => (cur.modifier_id === modSort.value ? acc + cur.value : acc),
          0
        ) ?? 0;
      return {
        ...tokenData,
        modSum,
      };
    });

    return lootListWithModSum?.sort((a, b) => {
      return b.modSum - a.modSum;
    });
  }, [shownLootList, jsonQueries, modSort]);

  return (
    <section className="px-2">
      <AccountsHeader modSort={modSort} setModSort={setModSort} />

      {accounts.map(
        ({ account, include, name }) =>
          include && lootState(account)?.canMint && <LootMint key={account} account={account} name={name}></LootMint>
      )}

      {sortedLootList && <LootList list={sortedLootList} lootState={lootState} />}
    </section>
  );
}
