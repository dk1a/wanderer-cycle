import { useMUD } from "./mud/MUDContext";
import { useWandererContext } from "./contexts/WandererContext";
import WandererSelect from "./pages/WandererSelect";
import CycleInfo from "./components/info/CycleInfo";

export const Home = () => {
  // const {components: { /*ActiveGuise, GuisePrototype, LoadingState*/ }, playerEntity,} = useMUD();
  const context = useWandererContext();
  const selectedWandererEntity = context.selectedWandererEntity;
  return <div>{selectedWandererEntity === undefined ? <WandererSelect /> : <CycleInfo />}</div>;
};
