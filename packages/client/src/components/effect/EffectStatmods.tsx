import { EffectStatmodData } from "../../mud/utils/getEffect";
import { EffectStatmod } from "./EffectStatmod";

export function EffectStatmods({
  statmods,
}: {
  statmods: EffectStatmodData[];
}) {
  return statmods.map(({ statmodEntity, value }, index) => (
    <EffectStatmod
      key={`${statmodEntity}-${index}`}
      statmodEntity={statmodEntity}
      value={value}
    />
  ));
}
