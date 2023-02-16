import { useCallback, useMemo } from "react";
import { tokenBaseNames, FTBases, TokenData } from "../../utils/tokenBases";
import { useIdentifyLoot } from "../../hooks/mutations/useIdentifyLoot";
import { checkTokenBase } from "../../utils/ERC1155SplitId";
import { ILoot } from "../../contracts";
import LootItem from "./LootItem";
import MethodButton from "../MethodButton";

export type LootListArgs = {
  list: TokenData[];
  lootState: (account: string) => ILoot.LootStateIOStructOutput | undefined;
};

export default function LootList({ list, lootState }: LootListArgs) {
  const identifyLoot = useIdentifyLoot();

  const getIdentifyAllButton = useCallback(
    (list: TokenData[]) => {
      const listForIdentification = list
        .filter(({ tokenId }) => checkTokenBase(tokenId, FTBases.LOOT_UNIDENTIFIED))
        .filter(({ account }) => lootState(account)?.canIdentify);
      const isAvailable = listForIdentification.length > 0;
      const isDisabled = !identifyLoot.enabled || identifyLoot.isLoading;
      return {
        isAvailable,
        isDisabled,
        callback: () => {
          if (!isAvailable || isDisabled) return;
          const accounts = new Set(listForIdentification.map(({ account }) => account));
          for (const account of accounts) {
            const accountLoot = listForIdentification.filter(({ account: _account }) => _account === account);
            const ids = accountLoot.map(({ tokenId }) => tokenId);
            const amounts = accountLoot.map(({ balance }) => balance);
            // identify
            // TODO mutate might not work like this, altho it probably does. Test it with > 1 unique accounts
            identifyLoot.write({
              recklesslySetUnpreparedArgs: [account, ids, amounts],
            });
          }
        },
      };
    },
    [identifyLoot, lootState]
  );

  const sections = useMemo(() => {
    return tokenBaseNames
      .sort(compareTokenBaseNames)
      .map((sectionBaseName) => {
        const sectionList = list.filter(({ baseName }) => baseName === sectionBaseName);
        return {
          sectionBaseName,
          sectionList,
          identifyAllButton: getIdentifyAllButton(sectionList),
        };
      })
      .filter(({ sectionList }) => sectionList.length > 0);
  }, [list, getIdentifyAllButton]);

  return (
    <div>
      <div className="text-dark-comment">{`// ================ `}</div>
      {sections.map(({ sectionBaseName, sectionList, identifyAllButton }) => (
        <section key={sectionBaseName} className="mt-4">
          <h4 className="text-dark-comment">{`// ${sectionBaseName}`}</h4>
          {identifyAllButton.isAvailable && (
            <MethodButton
              name="identifyAll"
              disabled={identifyAllButton.isDisabled}
              onClick={identifyAllButton.callback}
            />
          )}
          <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2">
            {sectionList.map((tokenData) => (
              <LootItem key={tokenData.uid} tokenData={tokenData} />
            ))}
          </div>
        </section>
      ))}
    </div>
  );
}

type TokenBaseName = (typeof tokenBaseNames)[number];
function compareTokenBaseNames(a: TokenBaseName, b: TokenBaseName) {
  // change sort order for specific tokenBaseNames
  function prefix(name: TokenBaseName) {
    if (name === "LOOT_UNIDENTIFIED") {
      return "!" + name;
    } else {
      return name;
    }
  }

  return prefix(a).localeCompare(prefix(b));
}
