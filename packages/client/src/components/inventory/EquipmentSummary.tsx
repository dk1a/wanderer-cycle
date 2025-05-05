import { useMemo } from "react";
import { LootAffix } from "../../mud/utils/getLootAffix";
import { EffectStatmodData } from "../../mud/utils/getEffect";
import { EffectStatmods } from "../effect/EffectStatmods";

export function EquipmentSummary({ affixes }: { affixes: LootAffix[] }) {
  const statmods: EffectStatmodData[] = useMemo(() => {
    return affixes.map(({ value, affixPrototype }) => ({
      value,
      statmodEntity: affixPrototype.statmodEntity,
    }));
  }, [affixes]);
  return <EffectStatmods statmods={statmods} />;
}
