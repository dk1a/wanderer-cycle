import { SyncState } from "@latticexyz/network";
import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./MUDContext";
import AppContent from "./AppContent";
import classes from './App.module.scss'

export const App = () => {
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
            <AppContent />
        )}

    </div>
  );
};
