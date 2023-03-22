import { SyncState } from "@latticexyz/network";
import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./mud/MUDContext";
import { AppRouter } from "./AppRouter";
import { WandererProvider } from "./contexts/WandererContext";
import { useState } from "react";
import { EntityIndex } from "@latticexyz/recs";

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

  const [selectedWandererEntity, selectWandererEntity] = useState<EntityIndex>();

  return (
    <div>
      {loadingState.state !== SyncState.LIVE ? (
        <div className="flex w-full items-center justify-center mt-10">
          <div className="text-center text-xl">
            {loadingState.msg} {"("}
            <span className="text-dark-number">{Math.floor(loadingState.percentage)}</span>
            {"%)"}
          </div>
        </div>
      ) : (
        <WandererProvider selectedWandererEntity={selectedWandererEntity} selectWandererEntity={selectWandererEntity}>
          <AppRouter />
        </WandererProvider>
      )}
    </div>
  );
};
