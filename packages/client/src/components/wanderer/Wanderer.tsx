import React, { ReactNode } from "react";
import classes from "./wanderer.module.scss";
import WandererImage from "./WandererImage";
import CustomButton from "../UI/button/CustomButton";
import { useWandererContext } from "../../contexts/WandererContext";

type wandererProps = {
  wandererEntity: any;
};

const Wanderer = ({ wandererEntity }: wandererProps) => {
  const { selectedWandererEntity, selectWandererEntity } = useWandererContext();
  console.log(wandererEntity);
  const wandererSelectHandler = () => {
    console.log(selectedWandererEntity);
  };

  return (
    <div className={classes.wanderer}>
      <div className="text-dark-type">
        HEADER
        {wandererEntity == selectedWandererEntity && "selected indicator placeholder"}
      </div>
      <WandererImage entity={wandererEntity} />
      <div className="">
        <CustomButton onClick={selectWandererEntity(wandererEntity)}>Select</CustomButton>
      </div>
    </div>
  );
};

export default Wanderer;
