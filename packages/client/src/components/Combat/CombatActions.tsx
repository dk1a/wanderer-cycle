import CustomButton from "../UI/Button/CustomButton";
import { useWandererContext } from "../../contexts/WandererContext";
import { useAttack, useResistance, useSpell } from "../../mud/hooks/charstat";

interface EncounterActionsProp {
  allowActions: boolean;
  disabled: boolean;
  onAttack: () => void;
}

export default function CombatActions({ allowActions, disabled, onAttack }: EncounterActionsProp) {
  const { cycleEntity } = useWandererContext();
  const attack = useAttack(cycleEntity);
  const resistance = useResistance(cycleEntity);
  const spell = useSpell(cycleEntity, attack);

  console.log("spell", spell);
  console.log("resistance", resistance);
  console.log("attack", attack);
  return (
    <>
      {allowActions && (
        <>
          <div className="flex-default justify-center mt-8">
            <CustomButton disabled={disabled} onClick={onAttack}>
              attack
            </CustomButton>
          </div>
        </>
      )}
    </>
  );
}
