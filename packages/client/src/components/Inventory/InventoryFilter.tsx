import { inventorySortOptions, useInventoryContext } from "../../contexts/InventoryContext";
import Select from "react-select";
import "../UI/Modal/modal.module.css";
import CustomInput from "../UI/Input/CustomInput";

export default function InventoryFilter() {
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
      <CustomInput value={filter} onChange={(e) => setFilter(e.target.value)} placeholder={"Search..."} />
    </div>
  );
}
