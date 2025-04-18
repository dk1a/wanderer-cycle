import { useWandererContext } from "../../contexts/WandererContext";
import { useStashCustom } from "../../mud/stash";
import { getLevel } from "../../mud/utils/charstat";
import BaseInfo from "./BaseInfo";

export default function CombatInfo() {
  const { enemyEntity } = useWandererContext();

  const levelData = useStashCustom((state) =>
    getLevel(state, enemyEntity, undefined),
  );

  return (
    <BaseInfo
      entity={enemyEntity}
      name={"Enemy"}
      levelData={levelData}
      locationName={null}
    />
  );
}
