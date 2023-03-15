import CustomInput from "../UI/Input/CustomInput";
import CustomButton from "../UI/Button/CustomButton";
import { useWandererEntities } from "../../mud/hooks/useWandererEntities";
import PartyPerson from "./PartyPerson";
import { truncateFromMiddle } from "../UI/CopyAndCopied/CopyAndCopied";
import { useWandererContext } from "../../contexts/WandererContext";
import { useActiveGuise } from "../../mud/hooks/guise";

export default function Party() {
  const wandererEntities = useWandererEntities();
  const { cycleEntity, onParty } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);

  return (
    <div className="h-full w-full">
      <h3 className="text-2xl text-dark-comment ml-4 mt-4">{"// party"}</h3>
      <div className="w-2/3 flex justify-center">
        <CustomInput placeholder={"Search..."}></CustomInput>
        <CustomButton onClick={onParty}>start</CustomButton>
      </div>
      <div>
        <div className="flex justify-around">
          {wandererEntities.map((wandererEntity) => (
            <div
              key={wandererEntity}
              className="border border-dark-400 w-1/4 h-12 my-4 text-dark-key cursor-pointer flex items-center justify-center"
            >
              <PartyPerson>{guise?.entityId && truncateFromMiddle(guise?.entityId, 13, "...")}</PartyPerson>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
