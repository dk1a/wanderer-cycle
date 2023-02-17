import CycleInfo from "../info/CycleInfo";
import InventoryInfo from "./InventoryInfo";
import InventoryList from "./InventoryList";

export default function Inventory() {
  return (
    <section>
      <CycleInfo />
      <InventoryList />
      <InventoryInfo />
    </section>
  );
}
