import CustomInput from "../UI/Input/CustomInput";
import { useInventoryContext } from "../../contexts/InventoryContext";
import Select, { ActionMeta } from "react-select";
import "../UI/Modal/modal.module.css";
import { useCallback } from "react";
type optionsData = {
  readonly value: string;
  readonly label: string;
};
export default function InventoryFilter() {
  const { filter, setFilter, sort, setSort } = useInventoryContext();

  const sortOptions: readonly optionsData[] = [
    { value: "ilvl", label: "ilvl" },
    { value: "name", label: "name" },
  ];

  const getValue = useCallback(() => {
    return filter ? sortOptions.find((i) => i.value === sort) : "";
  }, [sortOptions, sort]);

  const onChangeLoot = useCallback(
    (newValue: ActionMeta<optionsData>) => {
      setSort(newValue.value);
    },
    [setSort]
  );

  return (
    <div className="flex items-center w-full">
      <Select
        classNamePrefix={"custom-select"}
        placeholder={sort}
        value={getValue()}
        onChange={onChangeLoot}
        options={sortOptions}
      />
      <CustomInput value={filter} onChange={(e) => setFilter(e.target.value)} placeholder={"Search..."} />
    </div>
  );
}
