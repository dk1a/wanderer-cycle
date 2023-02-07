import { useGuiseEntities } from "../../../mud/hooks/useGuiseEntities";
import { useWandererSpawn } from "../../../mud/hooks/useWandererSpawn";
import Guise from "../../guise/Guise";
import * as querystring from "querystring";

export default function WandererSpawn() {
  const guiseEntities = useGuiseEntities();
  const wandererSpawn = useWandererSpawn();

  return (
    <div>
      <hr className="h-px my-8 bg-gray-200 border-0 dark:bg-gray-700" />
      <h3 className="m-10 text-2xl font-bold text-dark-200 ml-20">{"Select a Guise to Mint a New Wanderer"}</h3>

      {guiseEntities.map((guiseEntity) => (
        <div className="flex justify-center items-center flex-col" key={guiseEntity}>
          <Guise key={guiseEntity} entity={guiseEntity} onSelectGuise={wandererSpawn} />
        </div>
      ))}
    </div>
  );
}
