import { useGuiseEntities } from "../../mud/hooks/useGuiseEntities";
import { useWandererSpawn } from "../../mud/hooks/useWandererSpawn";
import Guise from "../Guise/Guise";

export default function WandererSpawn({ disabled }: boolean) {
  const guiseEntities = useGuiseEntities();
  const wandererSpawn = useWandererSpawn();

  return (
    <div>
      <h3 className="m-10 text-2xl font-bold text-dark-comment">{"//select a Guise to Mint a New Wanderer"}</h3>
      {guiseEntities.map((guiseEntity) => (
        <div className="flex justify-center items-center flex-col" key={guiseEntity}>
          <Guise key={guiseEntity} entity={guiseEntity} onSelectGuise={wandererSpawn} disabled={disabled} />
        </div>
      ))}
    </div>
  );
}
