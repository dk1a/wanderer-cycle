import { useWandererContext } from "../../contexts/WandererContext";
import { useLevel } from "../../mud/hooks/charstat";
import BaseInfo from "./BaseInfo";

export default function CombatInfo() {
  const { enemyEntity } = useWandererContext();

  const levelData = useLevel(enemyEntity, undefined);

  return <BaseInfo entity={enemyEntity} name={"Enemy"} levelData={levelData} locationName={null} />;
}
