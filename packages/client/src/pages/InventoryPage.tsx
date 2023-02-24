import Inventory from "../components/Inventory";
import { InventoryProvider } from "../contexts/InventoryContext";

export function InventoryPage() {
  return (
    <div>
      <InventoryProvider>
        <Inventory />
      </InventoryProvider>
    </div>
  );
}
