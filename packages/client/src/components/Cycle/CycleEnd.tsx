import CustomButton from "../UI/Button/CustomButton";
import { useMemo } from "react";

export function CycleEnd({ setIsToggled, isToggled }: { isToggled: boolean; setIsToggled: (val: boolean) => void }) {
  const onClickHandler = () => {
    alert("you gained 10 identity");
    setIsToggled(!isToggled);
  };

  const levelProps = useMemo(() => {
    // TODO add total exp data
    const exp = 10;
    const level = 1;

    return {
      name: "level",
      props: { exp, level },
    };
  }, []);
  return (
    <div className="flex flex-col items-center w-full">
      <div className="text-2xl text-dark-comment">{"// end"}</div>
      <div>
        <span>End</span>
        {levelProps.props.level <= 12 && <CustomButton onClick={onClickHandler}>click</CustomButton>}
      </div>
    </div>
  );
}
