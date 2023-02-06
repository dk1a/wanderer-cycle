import Tippy from '@tippyjs/react';
import 'tippy.js/dist/tippy.css'
import classes from './Guise.module.scss'
import { Fragment } from 'react';
import {useGuise} from "../../mud/hooks/useGuise";
import {useGuiseEntities} from "../../mud/hooks/useGuiseEntities";
import {useGuiseSkill} from "../../mud/hooks/useGuiseSkill";
import CustomButton from '../../utils/UI/button/CustomButton';
import TippyComment from '../TippyComment';
import 'tippy.js/animations/perspective.css';


interface GuiseProps {
  id: string,
  onSelectGuise?: (guiseId: string) => void,
}

export default function Guise({id, onSelectGuise,}: GuiseProps) {
  const guiseEntities = useGuiseEntities()
  const guise = useGuise(guiseEntities[0])
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


  const splitted = (name: string) => {
    const split = name.split('')
    const first = split[0].toUpperCase()
    const rest = [...split]
    rest.splice(0,1)
    return [first, ...rest].join('')
  }

  let content
  if (guise) {
    const statNames: (keyof typeof guise.gainMul & string)[] = ['strength', 'arcana', 'dexterity']

    content = <>
      <header className={classes.guise__header}>
        {guise.name.value}
      </header>
      <div className={classes.guise__comment}>
        Stat Multipliers
      </div>

      <div className='flex flex-col justify-start items-baseline border border-dark-400'>
        <Tippy content="Multiplier of gained stats" animation='perspective'>
          <div className="text-xl text-dark-key cursor-pointer ">GainMul</div>
        </Tippy>
        {statNames.map((statName) => (
          <Fragment key={statName}>
            <div className="text-dark-key flex p-1 m-1">{splitted(statName)}:
              <div className="text-dark-number mx-2">{guise.gainMul[statName]}</div>
            </div>
          </Fragment>
        ))}
      </div>
      <div className={classes.guise__comment}>
        <div className='w-28'>Skill</div>
        <div className='w-28 text-center'>CoolDown</div>
        <div className='w-28 text-center'>Level</div>
      </div>
      <div className="">
        {guises.map((skill) => (
          <div className='flex'>
            <Tippy content={skill.description.value} animation='perspective'>
              <div className='flex  w-36' key={skill}>{skill.name.value}</div>
            </Tippy>
            <Tippy content={`${skill.cooldown.timeValue}s`} animation='perspective'>
              <div className='w-32 text-center'>{skill.cooldown.timeValue}</div>
            </Tippy>
            <Tippy content={'1level'} animation='perspective'>
              <div className='w-32 text-center'>{skill.requiredLevel}</div>
            </Tippy>
          </div>
        ))}
      </div>
      {onSelectGuise !== undefined &&
          <div className="flex justify-center mb-2">
            <CustomButton
                className="btn-control"
                onClick={() => onSelectGuise(id)}>
              Mint
            </CustomButton>
          </div>
      }
    </>
  } else {
    content = <span className="text-dark-number">{id}</span>
  }

    return <div className={classes.guise__container}>
        {content}
    </div>
}

