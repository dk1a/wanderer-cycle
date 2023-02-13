import { AppliedEffect } from "../../mud/hooks/useEffectPrototype";
import classes from "./map.module.scss";
import Effect from "../Effect";
import CustomButton from "../UI/CustomButton/CustomButton";

interface MapProps {
  name: string;
  level: number;
  effects: AppliedEffect[] | undefined;
}
const Map = ({ name, level, effects }: MapProps) => {
  return (
    <div className={classes.map__container}>
      <h3 className={classes.map__header}>{name}</h3>
      <hr className={classes.map__hr} />
      <div className={classes.map__description}>
        {"//level: "}
        <span className={classes.map__stats}>{level}</span>
      </div>
      <hr className={classes.map__hr} />
      <div className={classes.map__description}>
        <span>{"//effects"}</span>
        {effects?.map((effect) => (
          <Effect key={effect.entity} {...effect} />
        ))}
      </div>
      <hr className={classes.map__hr} />
      <CustomButton>{"Enter"}</CustomButton>
    </div>
  );
};

export default Map;
