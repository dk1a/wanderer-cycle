import { Tooltip } from "react-tippy";

const TippySkill = ({ children, guises, key }: any) => {
  return (
    <Tooltip
      trigger="click"
      interactive
      html={
        <div className="text-dark-comment bg-dark-500 p-2 border border-dark-400">
          <ul>
            {guises.map((item) => (
              <li key={item.entityId}>CoolDown:{item.coolDown.timeValue}</li>
            ))}
          </ul>
        </div>
      }
    >
      {children}
    </Tooltip>
  );
};

export default TippySkill;
