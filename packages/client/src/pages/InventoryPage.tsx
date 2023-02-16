import { useWandererContext } from "../contexts/WandererContext";
import WandererSelect from "./WandererSelect";
import CycleInfo from "../components/info/CycleInfo";
import Inventory from "../components/Inventory";

const InventoryPage = () => {
  const { selectedWandererEntity } = useWandererContext();

  return (
    <div>
      {selectedWandererEntity === undefined ? (
        <WandererSelect />
      ) : (
        <div className="flex">
          <div className="w-64 flex-shrink-0">
            <CycleInfo />
          </div>
          <div className="w-full flex-grow">
            <Inventory />
          </div>
        </div>
      )}
    </div>
  );
};

export default InventoryPage;
