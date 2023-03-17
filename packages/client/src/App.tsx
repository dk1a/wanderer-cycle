import { SyncState } from "@latticexyz/network";
import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./mud/MUDContext";
import { AppRouter } from "./AppRouter";
import { useWandererContext } from "./contexts/WandererContext";
import { SecondAppRouter } from "./SecondRouter";
import { ToastContainer } from "react-toastify";

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

  const { mode, lightTheme } = useWandererContext();

  return (
    <div className={lightTheme ? "dark" : ""}>
      {loadingState.state !== SyncState.LIVE ? (
        <div className="flex w-full items-center justify-center mt-10">
          <div className="text-center text-xl">
            {loadingState.msg} {"("}
            <span className="text-dark-number">{Math.floor(loadingState.percentage)}</span>
            {"%)"}
          </div>
        </div>
      ) : !mode ? (
        <AppRouter />
      ) : (
        <SecondAppRouter />
      )}
      <ToastContainer />
    </div>
  );
};
