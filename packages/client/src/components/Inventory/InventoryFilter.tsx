import CustomSelect from "../UI/Select/CustomSelect";
import CustomInput from "../UI/Input/CustomInput";
import { useInventoryContext } from "../../contexts/InventoryContext";
import { useCallback } from "react";
import Select from "react-select";
import "../UI/Modal/modal.module.css";

export default function InventoryFilter() {
  const { filter, setFilter, sort, setSort } = useInventoryContext();

  const sortOptions = [
    { value: "ilvl", label: "ilvl" },
    { value: "name", label: "name" },
  ] as const;

  const getValue = useCallback(() => {
    return filter ? sortOptions.find((i) => i.value === sort) : "";
  }, [sortOptions, sort]);

  const onChangeLoot = useCallback(
    (newValue) => {
      setSort(newValue.value);
    },
    [setSort]
  );
  console.log("sort", sort);
  return (
    <div className="flex items-center justify-around w-full">
      <Select
        classNamePrefix={"custom-select"}
        placeholder={sort}
        value={getValue}
        onChange={onChangeLoot}
        options={sortOptions}
      />
      <CustomInput value={filter} onChange={(e) => setFilter(e.target.value)} placeholder={"Search..."} />
    </div>
  );
}
