import CustomSelect from "../UI/Select/CustomSelect";
import CustomInput from "../UI/Input/CustomInput";
import { useInventoryContext } from "../../contexts/InventoryContext";

const InventoryFilter = () => {
  const { filter, setFilter, sort, setSort } = useInventoryContext();

  const sortOptions = [
    { value: "name", name: "name" },
    { value: "ilvl", name: "ilvl" },
  ] as const;

  return (
    <>
      <CustomSelect placeholder={"Sort"} value={sort} onChange={setSort} options={sortOptions} />
      <CustomInput value={filter} onChange={(e) => setFilter(e.target.value)} placeholder={"Search..."} />
    </>
  );
};

export default InventoryFilter;
