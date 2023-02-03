import { SyncState } from "@latticexyz/network";
import { useComponentValue } from "@latticexyz/react";
import { Navbar } from "./components/Navbar";
import { useMUD } from "./mud/MUDContext";

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
    <div className="w-screen flex h-screen items-center
    flex-col bg-gradient-to-br from-black via-cyan-900 to-black">

      {loadingState.state !== SyncState.LIVE ? (
        <div>
          {loadingState.msg} ({Math.floor(loadingState.percentage)}%)
        </div>
      ) : (
        <Navbar />
      )}
    </div>
  );
};
