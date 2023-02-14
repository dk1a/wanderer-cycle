import Map from "../components/Map";
import { useWandererContext } from "../contexts/WandererContext";
import { useActiveGuise } from "../mud/hooks/useActiveGuise";
import { useEffectPrototype } from "../mud/hooks/useEffectPrototype";

const GlobalMaps = () => {
  const { cycleEntity } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);
  const skill = guise.skillEntities[0];
  const skillList = useEffectPrototype(skill);

  const mapList = [
    { name: "global basic map", lvl: 1, effects: [skillList] },
    { name: "global basic map", lvl: 2, effects: [skillList] },
    { name: "global basic map", lvl: 3, effects: [skillList] },
    { name: "global basic map", lvl: 4, effects: [skillList] },
    { name: "global basic map", lvl: 5, effects: [skillList] },
    { name: "global basic map", lvl: 6, effects: [skillList] },
    { name: "global basic map", lvl: 7, effects: [skillList] },
    { name: "global basic map", lvl: 8, effects: [skillList] },
    { name: "global basic map", lvl: 9, effects: [skillList] },
    { name: "global basic map", lvl: 10, effects: [skillList] },
    { name: "global basic map", lvl: 11, effects: [skillList] },
    { name: "global basic map", lvl: 12, effects: [skillList] },
  ];
  return (
    <div className="flex justify-around flex-wrap">
      {mapList.map((item) => (
        <Map key={item.lvl} name={item.name} level={item.lvl} effects={item.effects} />
      ))}
    </div>
  );
};

export default GlobalMaps;
