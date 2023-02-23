import CustomButton from "../UI/Button/CustomButton";

const LearnSkill = () => {
  return (
    <div>
      <div className="text-2xl text-dark-comment">{"// inventory"}</div>
      <div className="flex justify-around">
        <div className="border border-dark-400 w-44 h-36 text-dark-method text-center">Skill</div>
        <div className="h-1/2">
          <CustomButton>learn</CustomButton>
        </div>
      </div>
    </div>
  );
};

export default LearnSkill;
