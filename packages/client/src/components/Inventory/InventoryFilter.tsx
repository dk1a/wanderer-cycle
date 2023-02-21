import CustomSelect from "../UI/Select/CustomSelect";
import CustomInput from "../UI/Input/CustomInput";

type InventoryFilterProps = {
  filter: object;
  setFilter: void;
};
const InventoryFilter = ({ filter, setFilter }: InventoryFilterProps) => {
  return (
    <>
      <CustomSelect
        defaultValue={"Sort"}
        value={filter.sort}
        onChange={(selectedSort) => setFilter({ ...filter, sort: selectedSort })}
        option={[
          { value: "name", name: "name" },
          { value: "ilvl", name: "ilvl" },
        ]}
      />
      <CustomInput
        value={filter.query}
        onChange={(e) => setFilter({ ...filter, query: e.target.value })}
        placeholder={"Search..."}
      />
    </>
  );
};

export default InventoryFilter;
