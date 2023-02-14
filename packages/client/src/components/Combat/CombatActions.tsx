interface EncounterActionsProp {
  allowActions: boolean;
  disabled: boolean;
  onAttack: () => void;
}

export default function EncounterActions({ allowActions, disabled, onAttack }: EncounterActionsProp) {
  return (
    <>
      {allowActions && (
        <>
          <div className="flex-default justify-center mt-8">
            <button type="button" className="btn-method w-28" disabled={disabled} onClick={onAttack}>
              attack
            </button>
          </div>
        </>
      )}
    </>
  );
}
