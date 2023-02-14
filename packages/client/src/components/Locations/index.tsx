import { useCallStaticEncounterContext } from "../../contexts/CallStaticEncounterContext";
import EncounterTable from "./EncounterTable";

export default function Locations() {
  const { setLocationId } = useCallStaticEncounterContext();

  return (
    <section className="overflow-x-auto">
      <h4 className="text-dark-comment mb-2">
        {"// Locations (click a name to go there; click a col header to sort; hold shift to multisort)"}
      </h4>
      <EncounterTable
        onCellTrigger={(locationId, offset) => {
          setLocationId(locationId);
        }}
      />
    </section>
  );
}
