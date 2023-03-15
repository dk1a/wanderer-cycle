import { EntityID, EntityIndex } from "@latticexyz/recs";
import { LevelData, useLife, useMana } from "../../mud/hooks/charstat";
import { useLifeCurrent, useManaCurrent } from "../../mud/hooks/currents";

type PartyPersonProps = {
  entity: EntityIndex | undefined;
  name: string | undefined;
  entityId?: EntityID | undefined;
  levelData: LevelData;
};

export default function PartyPersonInfo({ name, levelData, entity, entityId }: PartyPersonProps) {
  const life = useLife(entity);
  const mana = useMana(entity);
  const lifeCurrent = useLifeCurrent(entity);
  const manaCurrent = useManaCurrent(entity);

  const currents = [
    {
      name: "life",
      value: lifeCurrent,
      maxValue: life,
    },
    {
      name: "mana",
      value: manaCurrent,
      maxValue: mana,
    },
  ];
  return (
    <div className={"bg-dark-500 border border-dark-400 p-2 m-[-10px]"}>
      <div className="flex justify-between items-center">
        <div>
          <span className="text-dark-type">{name}</span>
        </div>
        <div className="text-dark-key">
          lvl: <span className="text-dark-number">{levelData?.level}</span>
        </div>
      </div>
      <div>
        {currents.map(({ name, value, maxValue }) => (
          <div className="text-dark-key flex" key={name}>
            {name}:
            <div className="text-dark-key flex mx-1">
              <span className="text-dark-number">{value}</span>
              <span className="text-dark-200 mx-0.5">/</span>
              <span className="text-dark-number">{maxValue}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
