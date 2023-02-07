import { SkillType, useGuiseSkill } from "../../mud/hooks/useGuiseSkill";
import classes from "./skill.module.scss";

export default function Skill({ skill }: { skill: ReturnType<typeof useGuiseSkill> }) {
  return (
    <>
      <div className={classes.skill__container}>
        <div className={classes.skill__name}>{skill.name}</div>
        <div className={classes.skill__description}>{skill.description}</div>
        <div>
          <span className={classes.skill__key}>type: </span>
          <span className={classes.skill__string}>{skill.skillTypeName}</span>
        </div>
        {skill.skillType !== SkillType.PASSIVE && (
          <div>
            <span className={classes.skill__key}>cost: </span>
            <span className={classes.skill__number}>{skill.cost}</span>
            <span className={classes.skill__string}> mana</span>
          </div>
        )}
        {skill.duration.timeValue > 0 && (
          <div>
            <span className={classes.skill__key}>duration: </span>
            <span className={classes.skill__number}>{skill.duration.timeValue}</span>
            {/* TODO timeScopeId name map */}
            <span className={classes.skill__string}> placeholder{/*skill.duration.timeScopeId*/}</span>
          </div>
        )}
        {skill.cooldown.timeValue > 0 && (
          <div>
            <span className={classes.skill__key}>cooldown: </span>
            <span className={classes.skill__number}>{skill.cooldown.timeValue}</span>
            {/* TODO timeScopeId name map */}
            <span className={classes.skill__string}> Placeholder{/*skill.cooldown.timeScopeId*/}</span>
          </div>
        )}
      </div>

      {/* TODO skill statmods */}
      {/*statmods.length > 0 &&
      <>
        <div className="">
          <span className="text-dark-key">effect target: </span>
          <span className="text-dark-string">{targetTypeName}</span>
        </div>

        {item.skillData.modifiers.map(modifier =>
          <SkillEffectModifier key={modifier.modifierId} modifier={modifier} />
        )}
      </>
    */}
    </>
  );
}
