import { getEnumValues, PSTAT } from "contracts/enums";
import { CycleCombatRewardLog } from "../../mud/utils/combat";
import { pstatNames } from "../../mud/utils/experience";
import { BaseLoot } from "../inventory/BaseLoot";

interface CombatRewardLogProps {
  combatRewardLog: CycleCombatRewardLog;
}

export function CombatRewardLog({ combatRewardLog }: CombatRewardLogProps) {
  const pstats = getEnumValues(PSTAT);

  return (
    <div>
      {pstats.map((pstat) => (
        <div key={pstat} className="text-dark-string p-1 m-1">
          +
          <span className="text-dark-number">
            {combatRewardLog.exp[pstat]}{" "}
          </span>
          <span className="text-dark-key">{pstatNames[pstat]} </span>
          exp
        </div>
      ))}

      {combatRewardLog.lootRewards.map((lootData) => (
        <BaseLoot key={lootData.entity} lootData={lootData} />
      ))}
    </div>
  );
}
