import CycleInfo from "../info/CycleInfo";
import CurrentEquipment from "./CurrentEquipment";
import InventoryList from "./InventoryList";

export default function Inventory() {
  return (
    <section className="flex justify-around">
      <CycleInfo />
      <InventoryList />
      {/*<CurrentEquipment />*/}
    </section>
  );
}
