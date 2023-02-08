import { SyncState } from "@latticexyz/network";
import { useComponentValue } from "@latticexyz/react";
import classes from "./App.module.scss";
import { useMUD } from "./mud/MUDContext";
import WandererSelect from "./components/wanderer";

export const App = () => {
  const {
    components: { LoadingState },
    singletonEntity,
  } = useMUD();
  console.log(useMUD());

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
        <WandererSelect />
      )}
    </div>
  );
};
