import { useWandererContext } from "../contexts/WandererContext";
import { useAttack, useResistance } from "../mud/hooks/charstat";
import { elementNames, statmodElements } from "../mud/utils/elemental";

export function ElementalStatmods() {
  const { cycleEntity } = useWandererContext();
  const resistance = useResistance(cycleEntity);
  const attack = useAttack(cycleEntity);

  return (
    <div className="grid grid-cols-3 text-[15px] text-center mr-10">
      <div></div>
      <span className="text-dark-key w-1/2 text-center w-full" title="attack">
        attack
      </span>
      <div className="text-dark-key w-1/2 text-center w-full" title="resistance">
        resistance
      </div>
      <div className=" text-end">
        {Object.values(elementNames).map((elementName) => (
          <div className="text-dark-string" key={elementName} title={elementName}>
            {elementName}
          </div>
        ))}
      </div>
      <div>
        {statmodElements.map((statmodElement) => (
          <div className="text-dark-number text-center" key={statmodElement}>
            {resistance[statmodElement]}
          </div>
        ))}
      </div>
      <div>
        {statmodElements.map((statmodElement) => (
          <div className="text-dark-number text-center" key={statmodElement}>
            {attack[statmodElement]}
          </div>
        ))}
      </div>
    </div>
  );
}
