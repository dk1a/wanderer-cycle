import { SyncState } from "@latticexyz/network";
import { useComponentValue } from "@latticexyz/react";
import { useEffect } from "react";
import { Home } from "./Home";
import { useMUD } from "./MUDContext";

export const App = () => {
  const {
    world,
    components: { LoadingState },
    singletonEntity,
  } = useMUD();

  const loadingState = useComponentValue(LoadingState, singletonEntity, {
    state: SyncState.CONNECTING,
    msg: "Connecting",
    percentage: 0,
  });

  // TODO remove fake loading state when network sync works
  useEffect(() => {
    const t1 = setTimeout(() => {
      LoadingState.addOverride(world.entities[singletonEntity], {
        entity: singletonEntity,
        value: {
          state: SyncState.CONNECTING,
          msg: "Connecting",
          percentage: 50,
        },
      });
    }, 500);
    const t2 = setTimeout(() => {
      LoadingState.removeOverride(world.entities[singletonEntity]);
      LoadingState.addOverride(world.entities[singletonEntity], {
        entity: singletonEntity,
        value: {
          state: SyncState.LIVE,
          msg: "Live",
          percentage: 100,
        },
      });
    }, 1000);

    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
    }
  }, []);

  return (
    <div className="w-screen h-screen flex items-center justify-center">
      {loadingState.state !== SyncState.LIVE ? (
        <div>
          {loadingState.msg} ({Math.floor(loadingState.percentage)}%)
        </div>
      ) : (
        <Home />
      )}
    </div>
  );
};
