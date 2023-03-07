import { EntityIndex } from "@latticexyz/recs";
import { useEffect, useState } from "react";
import { useMUD } from "../../mud/MUDContext";

export default function WandererImage({ entity }: { entity: EntityIndex }) {
  const { world, systems } = useMUD();
  const [img, setImg] = useState("");

  useEffect(() => {
    (async () => {
      const entityId = world.entities[entity];
      const uri = await systems["system.WNFT"].callStatic.tokenURI(entityId);
      const json = await (await fetch(uri)).json();
      setImg(json.image);
    })();
  }, [world, systems, entity]);

  return <object data={img} className="w-64 h-64" />;
}
