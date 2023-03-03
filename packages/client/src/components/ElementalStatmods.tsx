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
    <div className="flex text-[15px]">
      <div className="flex flex-col justify-end text-center">
        <h5 className=" overflow-x-hidden text-dark-string" title="attack">
          attack
        </h5>
        <h5 className="text-dark-string" title="resistance">
          resistance
        </h5>
      </div>
      <div>
        <div>
          <div className="flex justify-evenly ml-2">
            {Object.values(elementNames).map((elementName) => (
              <div className="text-dark-key  mx-1" key={elementName} title={elementName}>
                {elementName}
              </div>
            ))}
          </div>
          <div className="flex justify-around text-center ">
            {statmodElements.map((statmodElement) => (
              <div className="text-dark-number text-center w-3" key={statmodElement}>
                {resistance[statmodElement]}
              </div>
            ))}
          </div>
          <div className="flex justify-around text-center ">
            {statmodElements.map((statmodElement) => (
              <div className="text-dark-number text-center w-6" key={statmodElement}>
                {attack[statmodElement]}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
