import { useMemo, useState } from "react";
import AccountsHeader from "./AccountsHeader";
// import LootList from "./LootList"
import LootMint from "./LootMint";
import { useLoot } from "../../mud/hooks/useLoot";
import { useGuiseEntities } from "../../mud/hooks/useGuiseEntities";

type Option = { value: string; label: string } | null;

export default function Inventory() {
  // const {accounts, lootState, shownLootList} = useWalletsLootContext()
  const [modSort, setModSort] = useState<Option>(null);
  const accounts = [
    {
      account: "account",
      include: true,
      name: "accountName",
    },
  ];
  const guiseEntities = useGuiseEntities();
  const { loot } = useLoot(guiseEntities[0]);

  // const lootIds = useMemo(() =>
  //   shownLootList?.map(({tokenId}) => tokenId) ?? [],
  //   [shownLootList]
  // )
  // const jsonQueries = useUrisJson(lootIds)

  // const sortedLootList = useMemo(() => {
  //   if (!modSort) return shownLootList
  //   const lootListWithModSum = shownLootList?.map((tokenData, index) => {
  //     const modSum = jsonQueries[index].data?.affixes?.reduce((acc, cur) =>
  //       cur.modifier_id === modSort.value ? acc + cur.value : acc,
  //       0
  //     ) ?? 0
  //     return {
  //       ...tokenData,
  //       modSum
  //     }
  //   })

  //   return lootListWithModSum?.sort((a, b) => {
  //     return b.modSum - a.modSum
  //   })
  // }, [shownLootList, jsonQueries, modSort])

  return (
    <section className="px-2">
      <AccountsHeader modSort={modSort} setModSort={setModSort} />

      {accounts.map(
        ({ account, include, name }) => include && <LootMint key={account} account={account} name={name}></LootMint>
      )}
      {/*<LootList />*/}
    </section>
  );
}
