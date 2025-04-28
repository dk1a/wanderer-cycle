import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import { getLevel } from "../../mud/utils/charstat";
import { BaseInfo } from "./BaseInfo";

export function EnemyInfo({ entity }: { entity: Hex }) {
  const levelData = useStashCustom((state) =>
    getLevel(state, entity, undefined),
  );

  return (
    <BaseInfo
      entity={entity}
      name={"Enemy"}
      levelData={levelData}
      locationName={null}
    />
  );
}
