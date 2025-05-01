import { Hex } from "viem";
import { CurrentEquipment } from "./CurrentEquipment";
import { InventoryList } from "./InventoryList";
import { InventoryProvider } from "./InventoryProvider";

export function Inventory({ ownerEntity }: { ownerEntity: Hex }) {
  return (
    <InventoryProvider targetEntity={ownerEntity}>
      <section className="flex justify-between w-full">
        <InventoryList ownerEntity={ownerEntity} />
        <CurrentEquipment ownerEntity={ownerEntity} />
      </section>
    </InventoryProvider>
  );
}
