import Inventory from "../components/Inventory";
import { InventoryProvider } from "../contexts/InventoryContext";

export function InventoryPage() {
  return (
    <div className="w-full">
      <InventoryProvider>
        <Inventory />
      </InventoryProvider>
    </div>
  );
}
