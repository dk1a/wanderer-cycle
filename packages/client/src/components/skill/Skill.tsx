import { timeTypeNames, skillTypeNames, targetTypeNames } from '../constants'
import { EffectModifierStructOutput } from '../contracts/Skill'
import { Fragment } from 'react'
import {useGuiseEntities} from "../../mud/hooks/useGuiseEntities";
import {useGuise} from "../../mud/hooks/useGuise";
import {useGuiseSkill} from "../../mud/hooks/useGuiseSkill";

interface SkillProps {
  id: string
}

export default function Skill({
  id
}: SkillProps) {
  const guiseEntities = useGuiseEntities()
  const guise = useGuise(guiseEntities[0])
  const guiseSkills = useGuiseSkill(guise.skillEntities[0])

  const guiseCleave = useGuiseSkill(guise.skillEntities[0])
  const guiseCharge = useGuiseSkill(guise.skillEntities[1])
  const guiseParry = useGuiseSkill(guise.skillEntities[2])
  const guiseOnslaught = useGuiseSkill(guise.skillEntities[3])
  const guiseToughness = useGuiseSkill(guise.skillEntities[4])
  const guiseThunderClap = useGuiseSkill(guise.skillEntities[5])
  const guisePreciseStrikes = useGuiseSkill(guise.skillEntities[6])
  const guiseBloodRage = useGuiseSkill(guise.skillEntities[7])
  const guiseRetaliation = useGuiseSkill(guise.skillEntities[8])
  const guiseLastStand = useGuiseSkill(guise.skillEntities[9])
  const guiseWeaponMastery = useGuiseSkill(guise.skillEntities[10])

  const guises = new Array(guiseCleave, guiseCharge, guiseParry,
    guiseOnslaught, guiseToughness, guiseThunderClap, guisePreciseStrikes,
    guiseBloodRage, guiseRetaliation, guiseLastStand, guiseWeaponMastery)

  console.log(guises)

  let content
  if (item) {
    const skillTypeName = skillTypeNames[item.skillData.skillType]
    const durationValue = item.skillData.duration.timeValue
    const durationTypeName = timeTypeNames[item.skillData.duration.timeType]
    const cooldownValue = item.skillData.cooldown.timeValue
    const cooldownTypeName = timeTypeNames[item.skillData.cooldown.timeType]
    const targetTypeName = targetTypeNames[item.skillData.effectTarget]

    content = <>
      <div className="text-dark-method text-lg">
        {item.skillData.name}
      </div>
      <div>
        <span className="text-dark-key">type: </span>
        <span className="text-dark-string">{skillTypeName}</span>
      </div>
      {skillTypeName !== 'passive' &&
        <div>
          <span className="text-dark-key">cost: </span>
          <span className="text-dark-number">{item.skillData.cost}</span>
          <span className="text-dark-string"> mana</span>
        </div>
      }
      {durationValue > 0 &&
        <div>
          <span className="text-dark-key">duration: </span>
          <span className="text-dark-number">{durationValue}</span>
          <span className="text-dark-string"> {durationTypeName}</span>
        </div>
      }
      {durationValue > 0 &&
        <div>
          <span className="text-dark-key">cooldown: </span>
          <span className="text-dark-number">{cooldownValue}</span>
          <span className="text-dark-string"> {cooldownTypeName}</span>
        </div>
      }

      <div className="text-dark-comment">
        {item.skillData.description}
      </div>

      {item.skillData.modifiers.length > 0 &&
        <>
          <div className="">
            <span className="text-dark-key">effect target: </span>
            <span className="text-dark-string">{targetTypeName}</span>
          </div>

          {item.skillData.modifiers.map(modifier =>
            <SkillEffectModifier key={modifier.modifierId} modifier={modifier} />
          )}
        </>
      }
    </>
  } else {
    content = <span className="text-dark-number">{id}</span>
  }

  return <div className="bg-dark-500 p-2 border border-dark-400 w-64">
    {content}
  </div>
}

function SkillEffectModifier({modifier}: {modifier: EffectModifierStructOutput}) {
  const { modifierList } = useContracts()
  const item = modifierList.find(e => e.id === modifier.modifierId)

  if (!item) {
    return <div className="text-dark-number">{modifier.modifierId}</div>
  }

  const nameParts = item.modifierData.name.split('#')
  return <div className="text-dark-200" key={modifier.modifierId}>
    {nameParts.map((namePart, index) => 
      <Fragment key={namePart}>
        {index !== 0 &&
          <span className="text-dark-number">{modifier.modifierValue}</span>
        }
        <span className="text-dark-string">{namePart}</span>
      </Fragment>
    )}
  </div>
}