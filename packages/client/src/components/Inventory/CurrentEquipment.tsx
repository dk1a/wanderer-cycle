import InventoryEquipment from "./InventoryEquipment";

const CurrentEquipment = () => {
  const separator = <hr className="h-px my-2 bg-dark-400 border-0" />;
  const locationName = null;
  const shirtsList = [
    { id: 1, title: "Helmet", type: "shirt", stats: "+30" },
    { id: 2, title: "Armor", type: "shirt", stats: "+100" },
    { id: 3, title: "Sword", type: "weapon", stats: "+200" },
    { id: 4, title: "Axe", type: "weapon", stats: "+150" },
    { id: 5, title: "Boots", type: "shirt", stats: "+40" },
    { id: 6, title: "Arrow", type: "weapon", stats: "+120" },
  ];

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
      {shirtsList.map((item) => (
        <InventoryEquipment
          key={item.id}
          style={{ width: "206px" }}
          title={item.title}
          stats={item.stats}
          type={item.type}
        />
      ))}
    </section>
  );
};

export default CurrentEquipment;
