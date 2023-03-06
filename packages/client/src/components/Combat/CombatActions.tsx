import CustomButton from "../UI/Button/CustomButton";

export default function CombatActions({ onAttack }: { onAttack: () => void }) {
  return (
    <>
      <div className="flex-default justify-center mt-8">
        <CustomButton onClick={onAttack}>attack</CustomButton>
      </div>
    </>
  );
}
