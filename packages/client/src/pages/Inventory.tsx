import { useWandererContext } from "../contexts/WandererContext";
import WandererSelect from "./WandererSelect";

const Inventory = () => {
  const { selectedWandererEntity } = useWandererContext();

  return <div>{selectedWandererEntity === undefined ? <WandererSelect /> : <div>inventory</div>}</div>;
};

export default Inventory;
