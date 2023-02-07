import Tippy from "@tippyjs/react";
import { useGuiseEntities } from "../../mud/hooks/useGuiseEntities";
import { useGuise } from "../../mud/hooks/useGuise";
import { useGuiseSkill } from "../../mud/hooks/useGuiseSkill";
import Skill from "../skill/Skill";

function GuiseSkill({ skill }: { skill: GuiseSkillDataExternalStructOutput }) {
  const guiseEntities = useGuiseEntities();
  const guise = useGuise(guiseEntities[0]);
  const guiseSkills = useGuiseSkill(guise.skillEntities[0]);

  if (!guise) {
    return <div className="text-dark-number">{skill.skillId}</div>;
  }

  return (
    <Tippy duration={0} placement="bottom" content={<Skill id={skill.skillId} />}>
      <li className="flex hover:bg-dark-highlight">
        <div className="w-4 mr-2 text-center text-dark-number">{skill.level}</div>
        <div className="text-dark-method">{guise.skillData.name}</div>
      </li>
    </Tippy>
  );
}
