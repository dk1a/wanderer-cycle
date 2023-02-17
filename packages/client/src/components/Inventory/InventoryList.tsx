import InventoryLoot from "./InventoryLoot";

const InventoryList = () => {
  const shirtsList = [1, 2, 3, 4, 5, 6, 7, 8];

  return (
    <div className="flex flex-col justify-center items-center">
      <div className="flex items-center justify-center">
        <div className="text-2xl text-dark-comment">{"//inventory"}</div>
      </div>
      <div className="flex items-center justify-center flex-wrap w-1/2">
        {shirtsList.map((item) => (
          <InventoryLoot key={item} />
        ))}
      </div>
    </div>
  );
};

export default InventoryList;
