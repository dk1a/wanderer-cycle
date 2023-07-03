import { useStatmodPrototype } from "../../mud/hooks/useStatmodPrototype";
import { EffectStatmodData } from "../../mud/utils/effectStatmod";

export function EffectStatmod({ protoEntity, value }: EffectStatmodData) {
  const statmodPrototype = useStatmodPrototype(protoEntity);
  const name = statmodPrototype.name;
  const nameParts = name.split("#");
  return (
    <div className="flex flex-wrap text-[14px]">
      {nameParts.map((namePart, index) => (
        <div key={namePart}>
          {index !== 0 && <span className="text-dark-number">{value}</span>}
          <span className="text-dark-string">{namePart}</span>
        </div>
      ))}
    </div>
  );
}
