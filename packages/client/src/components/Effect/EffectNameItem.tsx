import { EntityIndex } from "@latticexyz/recs";

export default function EffectNameItem({ entity }: { entity: EntityIndex }) {
  //const json = useUriJson(id)
  // TODO get data from tokenURI
  const json = { name: "itemPH" };

  return (
    <>
      <span className="text-dark-control mr-1">item</span>
      <span className="text-dark-method" title={json.name}>
        {json.name}
      </span>
    </>
  );
}
