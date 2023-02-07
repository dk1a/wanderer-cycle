import { SkillType, useGuiseSkill } from "../../mud/hooks/useGuiseSkill";

export default function Skill({ skill }: { skill: ReturnType<typeof useGuiseSkill> }) {
  return (
    <>
      <div className="text-dark-method text-lg">{skill.name}</div>
      <div>
        <span className="text-dark-key">type: </span>
        <span className="text-dark-string">{skill.skillTypeName}</span>
      </div>
      {skill.skillType !== SkillType.PASSIVE && (
        <div>
          <span className="text-dark-key">cost: </span>
          <span className="text-dark-number">{skill.cost}</span>
          <span className="text-dark-string"> mana</span>
        </div>
      )}
      {skill.duration.timeValue > 0 && (
        <div>
          <span className="text-dark-key">duration: </span>
          <span className="text-dark-number">{skill.duration.timeValue}</span>
          {/* TODO timeScopeId name map */}
          <span className="text-dark-string"> placeholder{/*skill.duration.timeScopeId*/}</span>
        </div>
      )}
      {skill.cooldown.timeValue > 0 && (
        <div>
          <span className="text-dark-key">cooldown: </span>
          <span className="text-dark-number">{skill.cooldown.timeValue}</span>
          {/* TODO timeScopeId name map */}
          <span className="text-dark-string"> placeholder{/*skill.cooldown.timeScopeId*/}</span>
        </div>
      )}

      <div className="text-dark-comment">{skill.description}</div>

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
