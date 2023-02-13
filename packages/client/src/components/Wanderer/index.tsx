import { EntityIndex } from "@latticexyz/recs";
import classes from "./wanderer.module.scss";
import WandererImage from "./WandererImage";
import CustomButton from "../UI/CustomButton/CustomButton";
import { useWandererContext } from "../../contexts/WandererContext";

export default function Wanderer({ wandererEntity }: { wandererEntity: EntityIndex }) {
  const { selectedWandererEntity, selectWandererEntity } = useWandererContext();
  const selectWandererHandler = () => {
    selectWandererEntity(wandererEntity);
  };

  return (
    <div className={classes.wanderer}>
      <div className="text-dark-type">HEADER</div>
      {wandererEntity == selectedWandererEntity && <span className="text-dark-string">{" (selected)"}</span>}
      <WandererImage entity={wandererEntity} />
      <div className="">
        <CustomButton onClick={selectWandererHandler}>Select</CustomButton>
      </div>
    </div>
  );
}
