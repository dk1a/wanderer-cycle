import { EntityIndex } from "@latticexyz/recs";
import { useSkill } from "../../mud/hooks/useSkill";
import Skill from "../Skill";
import "react-tippy/dist/tippy.css";
import Tippy from "@tippyjs/react";
import "../TippyComment/tippyTheme.scss";
import { left } from "@popperjs/core";
import { useCallback, useMemo } from "react";
import CustomButton from "../UI/Button/CustomButton";
import { useGuise } from "../../mud/hooks/useGuise";

export default function GuiseSkill({ entity }: { entity: EntityIndex }) {
  const skill = useSkill(entity);

  const levelProps = useMemo(() => {
    // TODO add total exp data
    const exp = 10;
    const level = 1;

    return {
      name: "level",
      props: { exp, level },
    };
  }, []);
  // const onLearnEnter = useCallback(() => {
  //   const
  // }, []);

  let content;
  if (skill) {
    content = (
      <Tippy
        key={entity}
        delay={100}
        offset={[0, 25]}
        placement={left}
        arrow={true}
        trigger={"click"}
        interactive
        content={
          <div style={{ padding: 0 }}>
            <Skill skill={skill} />
          </div>
        }
      >
        <div className="w-full flex cursor-pointer justify-between">
          <div className="flex">
            <div className="text-dark-number text-lg cursor-pointer">{skill.requiredLevel}.</div>
            <div className="text-dark-method text-lg cursor-pointer w-full">{skill.name}</div>
          </div>
          {levelProps.props.level >= skill.requiredLevel && (
            <CustomButton
            // onClick={onLearnEnter}
            >
              learn skill
            </CustomButton>
          )}
        </div>
      </Tippy>
    );
  } else {
    content = <span className="text-dark-number">{entity}</span>;
  }

  return <div className="bg-dark-500 p-2 border border-dark-400 flex">{content}</div>;
}
