// import {useState} from "react";
import { useWandererEntities } from "../../mud/hooks/useWandererEntities";
import { useWandererContext } from "../../contexts/WandererContext";
import WandererSpawn from "./WandererSpawn/WandererSpawn";
import CustomButton from "../UI/button/CustomButton";
import classes from "./wanderer.module.scss";
import WandererImage from "./WandererImage";

export default function WandererSelect() {
  const wandererEntities = useWandererEntities();
  const { selectWandererEntity, selectedWandererEntity } = useWandererContext();

  return (
    <div>
      {wandererEntities.length > 0 && (
        <section>
          <h3 className={classes.header}>{"Select a wanderer"}</h3>
          <div className={classes.wanderer__container}>
            {wandererEntities.map((wandererEntity) => (
              <div key={wandererEntity} className={classes.wanderer}>
                <div className="text-dark-300">
                  HEADER
                  {wandererEntity == selectedWandererEntity && "selected indicator placeholder"}
                </div>
                <WandererImage entity={wandererEntity} />

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
