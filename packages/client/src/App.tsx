import { SyncState } from "@latticexyz/network";
import { useComponentValue } from "@latticexyz/react";
import AppContent from "./AppContent";
import classes from './App.module.scss'
import {useMUD} from "./mud/MUDContext";


export const App = () => {
  // const guiseEntities = useGuiseEntities()
  // const guise = useGuise(guiseEntities[0])
  // const guiseSkills = useGuiseSkill(guise.skillEntities[0])
  //
  //
  // const guiseCleave = useGuiseSkill(guise.skillEntities[0])
  // const guiseCharge = useGuiseSkill(guise.skillEntities[1])
  // const guiseParry = useGuiseSkill(guise.skillEntities[2])
  // const guiseOnslaught = useGuiseSkill(guise.skillEntities[3])
  // const guiseToughness = useGuiseSkill(guise.skillEntities[4])
  // const guiseThunderClap = useGuiseSkill(guise.skillEntities[5])
  // const guisePreciseStrikes = useGuiseSkill(guise.skillEntities[6])
  // const guiseBloodRage = useGuiseSkill(guise.skillEntities[7])
  // const guiseRetaliation = useGuiseSkill(guise.skillEntities[8])
  // const guiseLastStand = useGuiseSkill(guise.skillEntities[9])
  // const guiseWeaponMastery = useGuiseSkill(guise.skillEntities[10])
  //
  // const guises = new Array(guiseCleave, guiseCharge, guiseParry,
  //   guiseOnslaught, guiseToughness, guiseThunderClap, guisePreciseStrikes,
  //   guiseBloodRage, guiseRetaliation, guiseLastStand, guiseWeaponMastery)
  //
  // console.log(guises)



  const {
    components: { LoadingState },
    singletonEntity,
  } = useMUD();
  console.log(useMUD())

  const loadingState = useComponentValue(LoadingState, singletonEntity, {
    state: SyncState.CONNECTING,
    msg: "Connecting",
    percentage: 0,
  });

  return (

    <div className={classes.parent}>
        {loadingState.state !== SyncState.LIVE ? (
            <div>
                {loadingState.msg} ({Math.floor(loadingState.percentage)}%)
            </div>
        ) : (
            <AppContent/>
        )}

    </div>
  );
};
