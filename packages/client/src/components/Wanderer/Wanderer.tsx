import { Hex } from "viem";
import { useWandererContext } from "../../mud/WandererProvider";
import { Button } from "../ui/Button";
import { WandererImage } from "./WandererImage";

interface WandererProps {
  readonly wandererEntity: Hex;
}

export function Wanderer({ wandererEntity }: WandererProps) {
  const { selectedWandererEntity, selectWandererEntity } = useWandererContext();

  return (
    <div
      onDoubleClick={() => console.log(wandererEntity)}
      className="border border-dark-400 pb-2 flex flex-col justify-between items-center bg-dark-500"
    >
      <WandererImage entity={wandererEntity} />
      <div className="mt-2 flex justify-around w-full">
        {wandererEntity === selectedWandererEntity && (
          <Button disabled={true}>
            <span>selected</span>
          </Button>
        )}
        {wandererEntity !== selectedWandererEntity && (
          <Button
            className="w-24"
            onClick={() => selectWandererEntity(wandererEntity)}
          >
            select
          </Button>
        )}
      </div>
    </div>
  );
}
