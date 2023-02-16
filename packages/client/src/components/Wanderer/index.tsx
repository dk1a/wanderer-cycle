import { EntityIndex } from "@latticexyz/recs";
import WandererImage from "./WandererImage";
import CustomButton from "../UI/CustomButton/CustomButton";
import { useWandererContext } from "../../contexts/WandererContext";

export default function Wanderer({ wandererEntity }: { wandererEntity: EntityIndex }) {
  const { selectedWandererEntity, selectWandererEntity } = useWandererContext();
  const selectWandererHandler = () => {
    selectWandererEntity(wandererEntity);
  };

  return (
    <div className="border border-dark-400 w-72 h-auto p-8 flex flex-col justify-between items-center bg-dark-500 transform delay-500">
      <div className="text-dark-type">HEADER</div>
      {wandererEntity == selectedWandererEntity && <span className="text-dark-string">{" (selected)"}</span>}
      <WandererImage entity={wandererEntity} />
      <div>
        <CustomButton onClick={selectWandererHandler}>Select</CustomButton>
      </div>
    </div>
  );
}
