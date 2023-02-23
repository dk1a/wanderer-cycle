import { useWandererContext } from "./contexts/WandererContext";
import WandererSelect from "./pages/WandererSelect";
import CycleInfo from "./components/info/CycleInfo";

export const Home = () => {
  const { selectedWandererEntity } = useWandererContext();

  return <div>{selectedWandererEntity === undefined ? <WandererSelect /> : <CycleInfo />}</div>;
};
