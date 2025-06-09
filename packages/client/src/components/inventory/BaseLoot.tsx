import { ReactNode } from "react";
import { LootSummary } from "./LootSummary";
import { LootData } from "../../mud/utils/getLoot";

type BaseLootProps = {
  lootData: LootData;
  children?: ReactNode;
};

export function BaseLoot({ lootData, children }: BaseLootProps) {
  const { name, tier, affixes } = lootData;

  return (
    <div className="text-dark-key p-1.5 flex flex-col justify-between border border-dark-400 bg-dark-500 w-64 m-2">
      <div className="flex items-start justify-between">
        <div className="text-lg text-dark-method flex box-border items-start">
          <span>{name}</span>
        </div>
        <span className="text-dark-key ml-1">
          tier:<span className="ml-1 text-dark-number">{tier}</span>
        </span>
      </div>
      <LootSummary affixes={affixes} />
      {children}
    </div>
  );
}
