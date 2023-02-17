import { Tooltip } from "react-tippy";
import TippyComment from "../TippyComment/TippyComment";

const InventoryLoot = ({ style }: any) => {
  return (
    <div className="flex items-center justify-center flex-wrap w-1/2" style={style}>
      <Tooltip arrow={true} animation="perspective" position="bottom" html={<TippyComment content="stats loot" />}>
        <div className="text-dark-key p-2 flex flex-col border border-dark-400 w-72" style={style}>
          <span className="text-xl text-dark-type flex-wrap flex">
            lootType:
            <span className="text-lg text-dark-number"> lootName</span>
          </span>
          <span className="text-[12px] text-dark-string">Lorem ipsum dolor sit amet.</span>
        </div>
      </Tooltip>
    </div>
  );
};

export default InventoryLoot;
