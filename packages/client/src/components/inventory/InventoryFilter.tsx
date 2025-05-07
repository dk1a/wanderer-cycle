import Select from "react-select";
import { useInventoryContext } from "./InventoryProvider";

export function InventoryFilter() {
  const { filter, setFilter, inventorySortOptions, sort, setSort } =
    useInventoryContext();

  return (
    <div className="flex items-center gap-2 justify-end w-full">
      <Select
        classNamePrefix={"custom-select"}
        className="w-64"
        placeholder={"select"}
        value={sort}
        onChange={setSort}
        options={inventorySortOptions}
      />
      <input
        className="custom-input"
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        placeholder={"Search..."}
      />
    </div>
  );
}
