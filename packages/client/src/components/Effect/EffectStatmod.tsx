import { useStatmodPrototype } from "../../mud/hooks/useStatmodPrototype";
import { EffectStatmodData } from "../../mud/utils/effectStatmod";

export function EffectStatmod({ protoEntity, value }: EffectStatmodData) {
  const statmodPrototype = useStatmodPrototype(protoEntity);
  const name = statmodPrototype.name;
  const nameParts = name.split("#");
  return (
    <div className="flex flex-wrap">
      {nameParts.map((namePart, index) => (
        <div key={namePart} className="">
          {index !== 0 && <span className="text-dark-number text-[14px]">{value}</span>}
          <span className="text-dark-string text-[14px]">{namePart}</span>
        </div>
      ))}
    </div>
  );
}
