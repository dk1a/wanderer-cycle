import Select from "react-select";
import { inventorySortOptions, useInventoryContext } from "./InventoryProvider";

export function InventoryFilter() {
  const { filter, setFilter, sort, setSort } = useInventoryContext();

  return (
    <div className="flex items-center w-full">
      <Select
        classNamePrefix={"custom-select"}
        placeholder={"select"}
        value={sort}
        onChange={setSort}
        options={inventorySortOptions}
      />
      <input
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        placeholder={"Search..."}
      />
    </div>
  );
}
