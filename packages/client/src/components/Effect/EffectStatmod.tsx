import { useStatmodPrototype } from "../../mud/hooks/useStatmodPrototype";
import { EffectStatmod } from "../../mud/utils/effectStatmod";
import ModifierName from "../ModifierName";

export function EffectModifier({ protoEntity, value }: EffectStatmod) {
  // TODO maybe get just the name?
  const statmodPrototype = useStatmodPrototype(protoEntity);
  const name = statmodPrototype.name;

  // TODO protoEntity is a 32byte id, display a part of it or something (it should still be copyable tho)
  if (!name) {
    return <div>{protoEntity}</div>;
  }

  return <ModifierName name={name} value={value} className="flex-wrap box-border" />;
}
