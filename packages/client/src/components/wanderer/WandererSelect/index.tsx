import CustomButton from "../../../utils/UI/button/CustomButton";
import testImg from "../../../utils/img/output.png";
import WandererSpawn from "./WandererSpawn";
// import {useState} from "react";
import classes from "./wandererSelect.module.scss";
import { useWandererEntities } from "../../../mud/hooks/useWandererEntities";
import { useWandererContext } from "../../../contexts/WandererContext";

export default function WandererSelect() {
  const wandererEntities = useWandererEntities();
  const { selectWandererEntity, selectedWandererEntity } = useWandererContext();

  return (
    <div>
      {wandererEntities.length > 0 && (
        <section>
          <h3 className={classes.header}>{"Select a wanderer"}</h3>
          <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2 justify-around">
            {wandererEntities.map((wandererEntity) => (
              <div key={wandererEntity}>
                <div className="text-dark-300">
                  HEADER
                  {wandererEntity == selectedWandererEntity && "selected indicator placeholder"}
                </div>
                <div className="h-auto m-5">
                  <img src={testImg} alt="test" className="h-60 w-58" />
                </div>

                <div className="">
                  <CustomButton onClick={() => selectWandererEntity(wandererEntity)}>Select</CustomButton>
                </div>
              </div>
            ))}
          </div>
        </section>
      )}
      <WandererSpawn />
    </div>
  );
}
