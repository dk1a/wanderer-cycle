import CurrentEquipment from "./CurrentEquipment";
import InventoryList from "./InventoryList";

export default function Inventory() {
  return (
    <section className="flex justify-between w-full">
      <InventoryList />
      <CurrentEquipment />
    </section>
  );
}
