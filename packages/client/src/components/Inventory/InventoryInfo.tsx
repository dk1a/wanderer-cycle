import InventoryLoot from "./InventoryLoot";

const InventoryInfo = () => {
  const separator = <hr className="h-px my-2 bg-dark-400 border-0" />;
  const locationName = null;
  const shirtList = [1, 2, 4, 5];

  return (
    <section className="flex flex-col w-52 bg-dark-500 border border-dark-400 h-screen absolute top-16 right-0">
      <h4 className="col-span-3 text-center text-lg text-dark-type font-medium">Current Equipment</h4>
      {locationName !== null && <div className="col-span-3 text-center text-dark-string">{locationName}</div>}
      <div className="text-dark-key p-2 flex">
        <span>
          lootType: <span>lootName</span>
        </span>
        <span className="text-dark-string">stats: Lorem ipsum dolor sit amet.</span>
      </div>
      {shirtList.map((item) => (
        <InventoryLoot key={item} style={{ width: "100%" }} />
      ))}
    </section>
  );
};

export default InventoryInfo;
