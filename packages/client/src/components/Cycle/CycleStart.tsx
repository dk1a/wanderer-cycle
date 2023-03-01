import { useMemo } from "react";
import CustomSelect from "../UI/Select/CustomSelect";
import CustomButton from "../UI/Button/CustomButton";
import { useGuises } from "../../mud/hooks/guise";

export function CycleStart({ isToggled, setIsToggled }: { isToggled: boolean; setIsToggled: (val: boolean) => void }) {
  const guises = useGuises();

  const onChangeHandler = () => {
    return;
  };
  const wheel = [
    { value: "", name: "Attainment" },
    { value: "", name: "Isolation" },
  ];
  const guiseOptions = useMemo(() => guises.map(({ name, entity }) => ({ name, value: entity })), [guises]);

  function onClickhandler() {
    setIsToggled(!isToggled);
  }

  return (
    <div className="flex flex-col w-full items-center">
      <span className="text-2xl text-dark-comment">{"// start"}</span>
      <div>
        <div className="flex w-96 mb-4">
          <span className="text-dark-string w-24">select a guise</span>
          <CustomSelect options={guiseOptions} placeholder={"select a guise"} onChange={onChangeHandler} />
        </div>
        <div className="flex w-96">
          <span className="text-dark-string w-24">select Wheel</span>
          <CustomSelect options={wheel} placeholder={"select a guise"} onChange={onChangeHandler} />
        </div>
        <div className="flex flex-col items-center text-start mt-4">
          <span className="text-dark-string">Reward</span>
          <span className="text-dark-key">
            identity: <span className="text-dark-number">10</span>
          </span>
          <span className="text-dark-key">
            identity pool:{" "}
            <span className="text-dark-number">
              20 <span className="text-dark-method">/</span> 50
            </span>
          </span>
        </div>
        <div className="flex items-center justify-center mt-4">
          <CustomButton onClick={onClickhandler}>start</CustomButton>
        </div>
      </div>
    </div>
  );
}
