import CustomSelect from "../UI/Select/CustomSelect";
import CustomInput from "../UI/Input/CustomInput";
import { useInventoryContext } from "../../contexts/InventoryContext";
export default function InventoryFilter() {
  const { filter, setFilter, sort, setSort, checked, setChecked } = useInventoryContext();

  const sortOptions = [
    { value: "ilvl", name: "ilvl" },
    { value: "name", name: "name" },
  ] as const;

  return (
    <>
      <CustomSelect placeholder={"Sort"} value={sort} onChange={setSort} options={sortOptions} />
      <CustomInput value={filter} onChange={(e) => setFilter(e.target.value)} placeholder={"Search..."} />
      <div className="flex items-center text-dark-string w-40">
        <input type={"checkbox"} checked={checked} onChange={() => setChecked(!checked)} />
        {checked ? <span className="ml-4">with category</span> : <span className="ml-4">without category</span>}
      </div>
    </>
  );
}
