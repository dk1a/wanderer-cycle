import { EntityIndex } from "@latticexyz/recs";
import WandererImage from "./WandererImage";
import CustomButton from "../UI/Button/CustomButton";
import { useWandererContext } from "../../contexts/WandererContext";

export default function Wanderer({ wandererEntity }: { wandererEntity: EntityIndex }) {
  const { selectedWandererEntity, selectWandererEntity } = useWandererContext();

  return (
    <div className="border border-dark-400 w-72 h-auto p-8 flex flex-col justify-between items-center bg-dark-500 transform delay-500">
      <WandererImage entity={wandererEntity} />
      <div className="mt-4">
        {wandererEntity === selectedWandererEntity && (
          <div className="text-dark-string flex items center justify-center text border border-dark-string py-0.5  w-[96px] h-[28px]">
            <span className="Selected font-medium">Selected</span>
          </div>
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
