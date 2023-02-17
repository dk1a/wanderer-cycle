import { useWandererContext } from "../contexts/WandererContext";
import WandererSelect from "./WandererSelect";

const InventoryPage = () => {
  const { selectedWandererEntity } = useWandererContext();

  // TODO maybe move this check higher up the tree, so it's not repeated in every page
  return <div>{selectedWandererEntity === undefined ? <WandererSelect /> : <div>inventory</div>}</div>;
};

export default InventoryPage;
