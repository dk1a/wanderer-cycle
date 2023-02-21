import { useInventoryContext } from "../../contexts/InventoryContext";

const CurrentEquipment = () => {
  const separator = <hr className="h-px my-2 bg-dark-400 border-0" />;
  const locationName = null;

  const { equipmentSlots } = useInventoryContext();

  return (
    <section className="flex flex-col w-52 bg-dark-500 border border-dark-400 h-screen absolute top-16 right-0">
      <h4 className="col-span-3 text-center text-lg text-dark-type font-medium">Current Equipment</h4>
      {/* TODO style this */}
      {equipmentSlots.map(({ entity, name, equipped, unequip }) => (
        <div key={entity}>
          <div>{name}</div>
          {equipped !== undefined && (
            <div>
              <div>{equipped.name}</div>
              <button onClick={() => unequip()}>unequip</button>
            </div>
          )}
        </div>
      ))}
    </section>
  );
};

export default CurrentEquipment;
