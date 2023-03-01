import { elementNames } from "../../constants";
import { CycleDataGetter } from "../../contracts/CycleDataGetter";

export default function ElementalStats({ attrs }: { attrs: CycleDataGetter.AttributesExternalStructOutput }) {
  const cols = elementNames.length;
  // https://tailwindcss.com/docs/content-configuration#dynamic-class-names
  // this should cause ts(2367) if const's length changes
  const gridColsClass = cols === 5 ? "grid-cols-6" : "";

  return (
    <div className={`grid ${gridColsClass}`}>
      <div></div>
      {/*{elementNames.map(elementName =>*/}
      {/*  <div className="text-dark-key overflow-x-hidden mr-2"*/}
      {/*       key={elementName} title={elementName}>*/}
      {/*    {elementName}*/}
      {/*  </div>*/}
      {/*)}*/}

      <h5 className="text-dark-key overflow-x-hidden mr-2" title="resistance">
        resistance
      </h5>
      {elementNames.map((elementName, index) => (
        <div className="text-dark-number" key={elementName}>
          {attrs.resistance[index]}
        </div>
      ))}

      <h5 className="text-dark-key overflow-x-hidden mr-2" title="attack">
        attack
      </h5>
      {elementNames.map((elementName, index) => (
        <div className="text-dark-number" key={elementName}>
          {attrs.attack[index]}
        </div>
      ))}
    </div>
  );
}
