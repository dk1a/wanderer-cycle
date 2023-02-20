import CustomButton from "../UI/Button/CustomButton";

interface EncounterActionsProp {
  allowActions: boolean;
  disabled: boolean;
  onAttack: () => void;
}

export default function CombatActions({ allowActions, disabled, onAttack }: EncounterActionsProp) {
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
