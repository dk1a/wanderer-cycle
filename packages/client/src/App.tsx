import { SyncState } from "@latticexyz/network";
import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./mud/MUDContext";
import { AppRouter } from "./AppRouter";

export const App = () => {
  const {
    components: { LoadingState },
    SingletonEntity,
  } = useMUD();

  const loadingState = useComponentValue(LoadingState, SingletonEntity, {
    state: SyncState.CONNECTING,
    msg: "Connecting",
    percentage: 0,
  });

  return (
    <div className="h-full">
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
