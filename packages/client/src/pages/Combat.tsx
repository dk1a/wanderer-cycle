import CombatInfo from "../components/Combat/CombatInfo";
import CombatResultView from "../components/Combat/CombatResultView";

const Combat = () => {
  // const { locationId, encounterResult } = useCallStaticEncounterContext()
  // const withLocation = !!locationId
  // const withResult = encounterResult !== EncounterResult.NONE
  const withResult = true;

  return <div>compatPage</div>;
};

export default Combat;

// <div className="overflow-x-auto w-full">
//   {withResult ? (
//     <div className="flex">
//       <div className="w-full flex-grow">
//         <CombatResultView
//           // encounterResult={encounterResult}
//         />
//       </div>
//       <div className="w-64 flex-shrink-0"></div>
//     </div>
//   ) : withLocation ? (
//     <div className="flex">
//       <div className="w-full flex-grow">
//         <Combat />
//       </div>
//       <div className="w-64 flex-shrink-0">
//         <CombatInfo />
//       </div>
//     </div>
//   ) : (
//     <div>{/*<Locations />*/}</div>
//   )}
// </div>
