import { useGuises } from "../../mud/hooks/guise";
import { useWandererSpawn } from "../../mud/hooks/useWandererSpawn";
import Guise from "../Guise/Guise";

export default function WandererSpawn({ disabled }: { disabled: boolean }) {
  const guises = useGuises();
  const wandererSpawn = useWandererSpawn();

  return (
    <div>
      <h3 className="m-10 text-2xl font-bold text-dark-comment">{"// select a Guise to Mint a New Wanderer"}</h3>
      {guises.map((guise) => (
        <div className="flex justify-center items-center flex-col" key={guise.entity}>
          <Guise guise={guise} onSelectGuise={wandererSpawn} disabled={disabled} />
        </div>
      ))}
    </div>
  );
}
