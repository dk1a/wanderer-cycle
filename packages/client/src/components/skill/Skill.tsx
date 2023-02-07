import TippySkill from "../tippyComment/TippySkill";

interface SkillProps {
  guises: any
}

export default function Skill({guises}: SkillProps) {
  let content
  if (guises) {
    content =
      <>
      <div>
        {guises.map(item => (
          <div className="text-dark-method text-lg cursor-pointer">{item.requiredLevel}.</div>
        ))}
      </div>
        <div>
          {guises.map(item => (
            <TippySkill guises={guises} key={item.entityId}>
              <div className="text-dark-method text-lg cursor-pointer">{item.name.value}</div>
            </TippySkill>
          ))}
        </div>
      </>
  } else {
    content = <span className="text-dark-number">{guises}</span>
  }

  return <div className="bg-dark-500 p-2 border border-dark-400 flex">
    {content}
  </div>
}

