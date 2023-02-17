import InventoryLoot from "./InventoryLoot";
import CustomSelect from "../UI/Select/CustomSelect";
import { useState } from "react";

const InventoryList = () => {
  const [inventoryList, setInventoryList] = useState([
    { id: 1, title: "Helmet", type: "shirt", stats: "+30" },
    { id: 2, title: "Armor", type: "shirt", stats: "+100" },
    { id: 3, title: "Sword", type: "weapon", stats: "+200" },
    { id: 4, title: "Axe", type: "weapon", stats: "+150" },
    { id: 5, title: "Boots", type: "shirt", stats: "+40" },
    { id: 6, title: "Arrow", type: "weapon", stats: "+120" },
  ]);
  const [selectedSort, setSelectedSort] = useState("");
  const sortList = (sort) => {
    setSelectedSort(sort);
    setInventoryList([...inventoryList].sort((a, b) => a[sort].localeCompare(b[sort])));
  };

  return (
    <div className="flex flex-col justify-center items-center">
      <div className="flex items-center justify-center">
        <div className="text-2xl text-dark-comment">{"//inventory"}</div>
      </div>
      <CustomSelect
        defaultValue={"Sort"}
        value={selectedSort}
        onChange={sortList}
        option={[
          { value: "title", name: "sorting by name" },
          { value: "type", name: "sorting by type" },
          { value: "stats", name: "sorting by stats" },
        ]}
      />
      <div className="flex items-center justify-center flex-wrap w-1/2">
        {inventoryList.map((item) => (
          <InventoryLoot key={item.id} title={item.title} stats={item.stats} type={item.type} />
        ))}
      </div>
    </div>
  );
};

export default InventoryList;
