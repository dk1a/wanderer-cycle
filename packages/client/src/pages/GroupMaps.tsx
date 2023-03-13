import { useWandererContext } from "../contexts/WandererContext";
import MultiLevelMaps from "../components/Map/MultiLevelMaps";
import { useLifeCurrent } from "../mud/hooks/currents";

export function GroupMaps() {
  const { cycleEntity } = useWandererContext();
  const lifeCurrent = useLifeCurrent(cycleEntity);

  const mapData = [
    {
      entity: 1637,
    },
  ];

  return (
    <div className="flex flex-col">
      {!lifeCurrent && (
        <div className="text-dark-comment m-4">{"// you are out of life, passTurn fully restores life and mana"}</div>
      )}
      <div className="flex justify-around flex-wrap">
        <div>
          <h4 className="text-dark-comment">{"// Global Boss maps"}</h4>
          <div className="flex flex-col gap-y-4 mr-4">
            {/*{mapData.map((entity) => (*/}
            {/*  <MultiLevelMaps />*/}
            {/*))}*/}
          </div>
        </div>
      </div>
    </div>
  );
}
