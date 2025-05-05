import { Inventory } from "../../components/inventory/Inventory";
import { useWandererContext } from "../../mud/WandererProvider";

export function InventoryPage() {
  const { cycleEntity } = useWandererContext();
  if (!cycleEntity) {
    throw new Error("Cycle entity is not defined");
  }

  return <Inventory ownerEntity={cycleEntity} />;
}
