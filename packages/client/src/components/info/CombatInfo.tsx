import BaseInfo from "./BaseInfo";
import { useWandererContext } from "../../contexts/WandererContext";
import { useLevel } from "../../mud/hooks/charstat";

export default function CombatInfo() {
  const { enemyEntity } = useWandererContext();

  const levelData = useLevel(enemyEntity, undefined);

  return <BaseInfo entity={enemyEntity} name={"Combat"} levelData={levelData} locationName={null} />;
}
