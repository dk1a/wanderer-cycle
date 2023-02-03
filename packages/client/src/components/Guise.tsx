import { Fragment } from 'react';
import Tippy from '@tippyjs/react';
import { useContracts } from '../contexts/ContractsContext'
import { GuiseSkillDataExternalStructOutput } from '../contracts/Guise';
import Skill from './Skill'
import TippyComment from './TippyComment'

interface GuiseProps {
    id: string,
    onSelectGuise?: (guiseId: string) => void,
}

export default function Guise({id, onSelectGuise,}: GuiseProps) {
    const { guiseList } = useContracts()
    const item = guiseList.find(e => e.id === id)

    let content
    if (item) {
        const statNames: (keyof typeof item.gainMul & string)[]
            = ['strength', 'arcana', 'dexterity']

        content = <>
            {onSelectGuise !== undefined &&
                <div className="flex justify-center mb-2">
                  <button type="button" className="btn-control"
                          onClick={() => onSelectGuise(id)}>
                    mint
                  </button>
                </div>
            }

            <div className="text-lg text-dark-type text-center">
                {item.name}
            </div>

            <div className="text-dark-comment">
                {'// stat multipliers'}
            </div>

            <div className="grid grid-cols-3">
                <div />
                <TippyComment content="Multiplier of gained stats">
                    <div className="text-sm text-dark-key">gainMul</div>
                </TippyComment>
                <TippyComment content="Multiplier of stat requirements to gain levels">
                    <div className="text-sm text-dark-key">levelMul</div>
                </TippyComment>

                {statNames.map((statName) => (
                    <Fragment key={statName}>
                        <div className="text-dark-key">{statName}:</div>
                        <div className="text-dark-number">{item.gainMul[statName]}</div>
                        <div className="text-dark-number">{item.levelMul[statName]}</div>
                    </Fragment>
                ))}
            </div>

            <div className="text-dark-comment">
                {'// level / skill'}
            </div>

            <ul className="grid grid-cols-1 divide-y divide-dark-400">
                {item.skillData.map((skill) => (
                    <GuiseSkill key={skill.skillId} skill={skill} />
                ))}
            </ul>
        </>
    } else {
        content = <span className="text-dark-number">{id}</span>
    }

    return <div className="grid grid-cols-1 w-64 p-4 border border-dark-400">
        {content}
    </div>
}

function GuiseSkill({skill}: {skill: GuiseSkillDataExternalStructOutput}) {
    const { skillList } = useContracts()
    const item = skillList.find(e => e.id === skill.skillId)

    if (!item) {
        return <div className="text-dark-number">{skill.skillId}</div>
    }

    return <Tippy duration={0} placement="bottom" content={<Skill id={skill.skillId} />}>
        <li className="flex hover:bg-dark-highlight">
            <div className="w-4 mr-2 text-center text-dark-number">{skill.level}</div>
            <div className="text-dark-method">{item.skillData.name}</div>
        </li>
    </Tippy>
}