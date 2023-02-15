import CombatInfo from "../components/Combat/CombatInfo";
import CombatResultView from "../components/Combat/CombatResultView";
import { useParams } from "react-router-dom";

const Combat = () => {
  // const { locationId, encounterResult } = useCallStaticEncounterContext()
  // const withLocation = !!locationId
  // const withResult = encounterResult !== EncounterResult.NONE
  const { entityId } = useParams();
  console.log(useParams);

  return <div className="overflow-x-auto w-full">{entityId}</div>;
};

export default Combat;

// {withResult ? (
//   <div className="flex">
//     <div className="w-full flex-grow">
//       <CombatResultView
//         // encounterResult={encounterResult}
//       />
//     </div>
//     <div className="w-64 flex-shrink-0"></div>
//   </div>
// ) : withLocation ? (
//   <div className="flex">
//     <div className="w-full flex-grow">
//       <Combat />
//     </div>
//     <div className="w-64 flex-shrink-0">
//       <CombatInfo />
//     </div>
//   </div>
// ) : (
//   <div>{/*<Locations />*/}</div>
// )}
