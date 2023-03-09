import { useGuises } from "../../mud/hooks/guise";
import { useWandererSpawn } from "../../mud/hooks/useWandererSpawn";
import Guise from "../Guise/Guise";

export default function WandererSpawn({ disabled }: { disabled: boolean }) {
  const guises = useGuises();
  const wandererSpawn = useWandererSpawn();

  return (
    <div>
      {guises.map((guise) => (
        <div className="flex justify-center items-center flex-col" key={guise.entity}>
          <Guise guise={guise} onSelectGuise={wandererSpawn} disabled={disabled} />
        </div>
      ))}
    </div>
  );
}
