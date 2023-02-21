import CustomButton from "../UI/Button/CustomButton";

export default function CombatResultView() {
  return (
    <section className="p-2 flex justify-around flex-col w-64 h-36 border border-dark-400 mt-10 ">
      <h3 className="text-center text-dark-string">Result</h3>
      <div className="flex justify-center w-full">
        <CustomButton>{"repeat"}</CustomButton>
        <CustomButton>{"close"}</CustomButton>
      </div>
    </section>
  );
}
