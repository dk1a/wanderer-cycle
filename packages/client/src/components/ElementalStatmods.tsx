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
    <div className="flex flex-col text-[15px]">
      <div className="flex text-center justify-center ml-10">
        <h5 className=" overflow-x-hidden text-dark-string mr-4" title="attack">
          attack
        </h5>
        <h5 className="text-dark-string" title="resistance">
          resistance
        </h5>
      </div>
      <div className="flex">
        <div className="flex flex-col text-end mx-4">
          {Object.values(elementNames).map((elementName) => (
            <div className="text-dark-key" key={elementName} title={elementName}>
              {elementName}
            </div>
          ))}
        </div>
        <div className="flex flex-col text-center mx-4">
          {statmodElements.map((statmodElement) => (
            <div className="text-dark-number text-center" key={statmodElement}>
              {resistance[statmodElement]}
            </div>
          ))}
        </div>
        <div className="flex flex-col text-center mx-10 ">
          {statmodElements.map((statmodElement) => (
            <div className="text-dark-number text-center" key={statmodElement}>
              {attack[statmodElement]}
            </div>
          ))}
        </div>
      </div>
      <div></div>
    </div>
  );
}
