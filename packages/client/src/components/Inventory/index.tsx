import { useInventoryContext } from "../../contexts/InventoryContext";
import CycleInfo from "../info/CycleInfo";
import CurrentEquipment from "./CurrentEquipment";
import InventoryList from "./InventoryList";

export default function Inventory() {
  const { equipmentList, presentProtoEntityIds, filter } = useInventoryContext();

  return (
    <section className="flex justify-around">
      <CycleInfo />
      <InventoryList equipmentList={equipmentList} presentProtoEntityIds={presentProtoEntityIds} filter={filter} />
      <CurrentEquipment />
    </section>
  );
}
