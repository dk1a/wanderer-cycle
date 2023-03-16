import { EntityIndex } from "@latticexyz/recs";
import WandererImage from "./WandererImage";
import CustomButton from "../UI/Button/CustomButton";
import { useWandererContext } from "../../contexts/WandererContext";

export default function Wanderer({
  wandererEntity,
  setActive,
}: {
  wandererEntity: EntityIndex;
  active: boolean;
  setActive: (arg0: boolean) => boolean;
}) {
  const { selectedWandererEntity, selectWandererEntity } = useWandererContext();

  return (
    <div className="border border-dark-400 w-72 h-auto py-2 px-4 flex flex-col justify-between items-center bg-dark-500 transform delay-500">
      <span className="text-dark-control text-end w-full cursor-pointer" onClick={() => setActive(true)}>
        ...
      </span>
      <WandererImage entity={wandererEntity} />
      <div className="mt-4 flex justify-around w-full">
        {wandererEntity === selectedWandererEntity && (
          <CustomButton disabled={true}>
            <span className="Selected font-medium">Selected</span>
          </CustomButton>
        )}
        {wandererEntity !== selectedWandererEntity && (
          <CustomButton style={{ width: "6rem" }} onClick={() => selectWandererEntity(wandererEntity)}>
            Select
          </CustomButton>
        )}
      </div>
    </div>
  );
}
