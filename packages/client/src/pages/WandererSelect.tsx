import CustomButton from "../utils/UI/button/CustomButton";
import Wanderer from "../components/wanderer/Wanderer";
import testImg from '../utils/img/output.png'
import WandererCreate from "../components/wanderer/WandererCreate";

export default function WandererSelect() {
    const wandererList = [1, 2];

    return <div className="">
        {wandererList.length > 0 &&
            <section>
              <h3 className="m-10 text-2xl font-bold text-dark-200 ml-20">
                  {'Select a wanderer'}
              </h3>
              <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2 justify-around">
                  {wandererList.map((wandererId) => (
                     <Wanderer key={wandererId}>
                         <div className='text-dark-300'>
                             HEADER
                         </div>
                         <div className='h-auto m-5'>
                             <img src={testImg} alt="test" className='h-40'/>
                         </div>
                         <div className='text-center text-dark-300 mb-2'>
                             <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Esse, pariatur!</p>
                         </div>
                         <div className=''>
                             <CustomButton>Select</CustomButton>
                         </div>
                     </Wanderer>
                  ))}
                <WandererCreate/>
              </div>
            </section>
        }
    </div>
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