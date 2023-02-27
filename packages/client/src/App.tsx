import { SyncState } from "@latticexyz/network";
import { useComponentValue } from "@latticexyz/react";
import classes from "./App.module.scss";
import { useMUD } from "./mud/MUDContext";
import { AppRouter } from "./AppRouter";

export const App = () => {
  const {
    components: { LoadingState },
    singletonEntity,
  } = useMUD();

  const loadingState = useComponentValue(LoadingState, singletonEntity, {
    state: SyncState.CONNECTING,
    msg: "Connecting",
    percentage: 0,
  });

  return (
    <div className={classes.App}>
      {loadingState.state !== SyncState.LIVE ? (
        <div>
          {loadingState.msg} ({Math.floor(loadingState.percentage)}%)
        </div>
      ) : (
        <AppRouter />
      )}
    </div>
  );
};
