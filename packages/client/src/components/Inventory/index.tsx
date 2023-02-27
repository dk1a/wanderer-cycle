import CurrentEquipment from "./CurrentEquipment";
import InventoryList from "./InventoryList";

export default function Inventory() {
  return (
    <section className="flex justify-between">
      <InventoryList />
      <CurrentEquipment />
    </section>
  );
}
