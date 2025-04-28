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
    <div className="border border-dark-400 min-h-[300px] min-w-[200px] h-auto py-2 px-4 flex flex-col justify-between items-center bg-dark-500 transform delay-500">
      <WandererImage entity={wandererEntity} />
      <div className="mt-4 flex justify-around w-full">
        {wandererEntity === selectedWandererEntity && (
          <Button disabled={true}>
            <span className="Selected font-medium">Selected</span>
          </Button>
        )}
        {wandererEntity !== selectedWandererEntity && (
          <Button
            className={"w-24"}
            onClick={() => selectWandererEntity(wandererEntity)}
          >
            Select
          </Button>
        )}
      </div>
    </div>
  );
}
