import CustomButton from "../../../utils/UI/button/CustomButton";
import testImg from "../../../utils/img/output.png";
import WandererSpawn from "./WandererSpawn";
// import {useState} from "react";
import classes from "./wandererSelect.module.scss";
import { useWandererEntities } from "../../../mud/hooks/useWandererEntities";
import { useWandererContext } from "../../../contexts/WandererContext";

export default function WandererSelect() {
  const wandererEntities = useWandererEntities();
  const { selectWandererEntity, selectedWandererEntity } = useWandererContext();

  return (
    <div className="">
      {wandererEntities.length > 0 && (
        <section>
          <h3 className={classes.header}>{"Select a wanderer"}</h3>
          <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2 justify-around">
            {wandererEntities.map((wandererEntity) => (
              <div key={wandererEntity}>
                <div className="text-dark-300">
                  HEADER
                  {wandererEntity == selectedWandererEntity && "selected indicator placeholder"}
                </div>
                <div className="h-auto m-5">
                  <img src={testImg} alt="test" className="h-60 w-58" />
                </div>

                <div className="">
                  <CustomButton onClick={() => selectWandererEntity(wandererEntity)}>Select</CustomButton>
                </div>
              </div>
            ))}
          </div>
        </section>
      )}

      <WandererSpawn />
    </div>
  );
}

// import { useState, useEffect } from 'react'
// import { useWeb3React } from '@web3-react/core'
// import Web3ReactManager from '../components/Web3ReactManager'
// import { useWandererContext } from '../contexts/WandererContext'
// import WandererImage from './WandererImage'
// import WandererMint from './WandererMint'
//
// export default function WandererSelect() {
//     const { active } = useWeb3React()
//     const [showMint, setShowMint] = useState(false)
//     const { wandererList, selectedWandererId, selectWandererId } = useWandererContext()
//
//     useEffect(() => {
//         setShowMint(wandererList.length < 4)
//     }, [wandererList])
//
//     if (!active) {
//         return <Web3ReactManager />
//     } else {
//         return <div className="">
//             {wandererList.length > 0 &&
//                 <section>
//                   <h4 className="text-lg text-dark-comment">
//                       {'// select a wanderer'}
//                   </h4>
//
//                   <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2">
//                       {wandererList.map((wandererId) => (
//                           <div key={wandererId.toString()}>
//                               <WandererImage id={wandererId} />
//
//                               <div className="flex justify-center z-10 -mt-5">
//                                   {selectedWandererId === wandererId &&
//                                       <div className="text-dark-control bg-dark-600 text-lg p-1 pr-8 pl-8 border border-dark-400">
//                                         selected
//                                       </div>
//                                   }
//                                   {selectedWandererId !== wandererId &&
//                                       <button type="button" className="btn-control"
//                                               onClick={() => selectWandererId(wandererId)}>
//                                         select
//                                       </button>
//                                   }
//                               </div>
//                           </div>
//                       ))}
//                   </div>
//                 </section>
//             }
//
//             {showMint && <WandererMint />}
//         </div>
//     }
// }
