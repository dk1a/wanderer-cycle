import { useWandererContext } from "../contexts/WandererContext";
import { useAttack, useResistance } from "../mud/hooks/charstat";
import { elementNames, statmodElements } from "../mud/utils/elemental";

export function ElementalStatmods() {
  const cols = statmodElements.length;
  // https://tailwindcss.com/docs/content-configuration#dynamic-class-names
  // this should cause ts(2367) if const's length changes
  const gridColsClass = cols === 5 ? "grid-cols-6" : "";

  const { cycleEntity } = useWandererContext();
  const resistance = useResistance(cycleEntity);
  const attack = useAttack(cycleEntity);

  return (
    <div className={`grid ${gridColsClass}`}>
      <div></div>
      {Object.values(elementNames).map((elementName) => (
        <div className="text-dark-key overflow-x-hidden mr-2" key={elementName} title={elementName}>
          {elementName}
        </div>
      ))}

      <h5 className="text-dark-key overflow-x-hidden mr-2" title="resistance">
        resistance
      </h5>
      {statmodElements.map((statmodElement) => (
        <div className="text-dark-number" key={statmodElement}>
          {resistance[statmodElement]}
        </div>
      ))}

      <h5 className="text-dark-key overflow-x-hidden mr-2" title="attack">
        attack
      </h5>
      {statmodElements.map((statmodElement) => (
        <div className="text-dark-number" key={statmodElement}>
          {attack[statmodElement]}
        </div>
      ))}
    </div>
  );
}
