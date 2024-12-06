import { useGuises } from "../../mud/hooks/guise";
import Guise from "../Guise/Guise";
import { useSpawnWanderer } from "../../mud/hooks/useSpawnWanderer";

export default function WandererSpawn({ disabled }: { disabled: boolean }) {
  const guises = useGuises();
  const spawnWanderer = useSpawnWanderer();

  return (
    <div>
      {guises.map((guise) => (
        <Guise
          key={guise.entity}
          guise={guise}
          disabled={disabled}
          onSelectGuise={spawnWanderer}
        />
      ))}
    </div>
  );
}
