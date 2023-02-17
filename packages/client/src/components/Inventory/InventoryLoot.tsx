import { Tooltip } from "react-tippy";
import TippyComment from "../TippyComment/TippyComment";

const InventoryLoot = ({ title, stats, style, type }: any) => {
  return (
    <div className="flex items-center justify-center flex-wrap w-1/2" style={style}>
      <Tooltip arrow={true} animation="perspective" position="bottom" html={<TippyComment content={stats} />}>
        <div className="text-dark-key p-2 flex flex-col border border-dark-400 w-72" style={style}>
          <span className="text-xl text-dark-type flex-wrap flex">
            {title}
            <span className="text-lg text-dark-string mx-1">{type}</span>
          </span>
          <span className="text-[12px] text-dark-number">{stats}</span>
        </div>
      </Tooltip>
    </div>
  );
};

export default InventoryLoot;
