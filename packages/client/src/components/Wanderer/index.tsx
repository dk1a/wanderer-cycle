import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Hex } from "viem";
import { useWandererContext } from "../../contexts/WandererContext";
import { formatEntity } from "../../mud/utils/format";
import { Button } from "../utils/Button/Button";

interface WandererProps {
  wandererEntity: Hex;
}

export default function Wanderer({ wandererEntity }: WandererProps) {
  const { selectedWandererEntity, selectWandererEntity } = useWandererContext();
  const navigate = useNavigate();

  useEffect(() => {
    const saved = sessionStorage.getItem("selectedWandererEntity");
    if (saved) {
      selectWandererEntity(saved as Hex);
    }
  }, [selectWandererEntity]);

  const handleSelectWanderer = (wanderer: Hex) => {
    sessionStorage.setItem("selectedWandererEntity", wanderer);
    selectWandererEntity(wanderer);
    navigate("/maps");
  };

  return (
    <div className="border border-dark-400 min-h-[300px] min-w-[200px] h-auto py-2 px-4 flex flex-col justify-between items-center bg-dark-500 transform delay-500">
      <h3 className={"text-dark-type"}>{formatEntity(wandererEntity)}</h3>
      {/*<WandererImage entity={wandererEntity}/>*/}
      <div className="mt-4 flex justify-around w-full">
        {wandererEntity === selectedWandererEntity && (
          <Button disabled={true}>
            <span className="Selected font-medium">Selected</span>
          </Button>
        )}
        {wandererEntity !== selectedWandererEntity && (
          <Button
            className={"w-24"}
            onClick={() => handleSelectWanderer(wandererEntity)}
          >
            Select
          </Button>
        )}
      </div>
    </div>
  );
}
