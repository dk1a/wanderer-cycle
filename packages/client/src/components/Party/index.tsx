import { useMemo } from "react";
import { useLevel } from "../../mud/hooks/charstat";
import { useWandererEntities } from "../../mud/hooks/useWandererEntities";
import { useWandererContext } from "../../contexts/WandererContext";
import { useActiveGuise } from "../../mud/hooks/guise";
import { truncateFromMiddle } from "../UI/CopyAndCopied/CopyAndCopied";
import PartyPerson from "./PartyPerson";
import PartyPersonInfo from "./PartyPersonInfo";
import CustomInput from "../UI/Input/CustomInput";
import CustomButton from "../UI/Button/CustomButton";
import Tippy from "@tippyjs/react";
import { right } from "@popperjs/core";

export default function Party() {
  const wandererEntities = useWandererEntities();
  const { cycleEntity, onParty } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);

  const guiseMul = useMemo(() => guise?.levelMul, [guise]);
  const levelData = useLevel(cycleEntity, guiseMul);

  return (
    <>
      <h4 className="text-dark-comment ml-4">{"// Party"}</h4>
      <div className="border border-dark-400 w-72 h-96 ml-5 flex flex-col items-center mb-4">
        <div className="flex items-center justify-center mt-4 w-4/5">
          <CustomInput placeholder={"Search..."}></CustomInput>
          <CustomButton className="border-0" onClick={onParty}>
            start
          </CustomButton>
        </div>
        {wandererEntities.map((entity) => (
          <>
            <Tippy
              key={entity}
              delay={100}
              offset={[0, 20]}
              placement={right}
              arrow={true}
              interactive
              content={
                <div style={{ padding: 0 }}>
                  <div className={"bg-dark-500 border border-dark-400 p-2 m-[-10px] w-36"}>
                    <PartyPersonInfo entity={cycleEntity} name={guise?.name} levelData={levelData} />
                  </div>
                </div>
              }
            >
              <div className="border border-dark-400 w-4/5 h-12 my-4 text-dark-key cursor-pointer flex items-center justify-center">
                <PartyPerson name={guise?.entityId && truncateFromMiddle(guise?.entityId, 13, "...")} />
              </div>
            </Tippy>
          </>
        ))}
      </div>
    </>
  );
}
