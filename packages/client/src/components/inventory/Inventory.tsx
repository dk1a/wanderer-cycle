import { Hex } from "viem";
import { EquipmentSlots } from "./EquipmentSlots";
import { InventoryList } from "./InventoryList";
import { InventoryProvider } from "./InventoryProvider";

export function Inventory({ ownerEntity }: { ownerEntity: Hex }) {
  return (
    <InventoryProvider targetEntity={ownerEntity}>
      <InventoryList ownerEntity={ownerEntity} />
      <EquipmentSlots ownerEntity={ownerEntity} />
    </InventoryProvider>
  );
}
