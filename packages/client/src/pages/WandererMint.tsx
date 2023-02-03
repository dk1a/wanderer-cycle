// import { useContracts } from '../contexts/ContractsContext'
// import { useMintWanderer } from '../hooks/useWanderer'
// import Guise from '../components/Guise'
import { useGuiseList } from '../mud/hooks/useGuiseList';
import testImg from '../utils/img/output.png'
import plus from '../utils/img/plus-square.svg'

export default function WandererMint() {
    const guiseList = useGuiseList();
    
    // //const [guiseId, setGuiseId] = useState('')
    // const { guiseList } = useContracts()
    // const { mintWanderer } = useMintWanderer()
    //
    // const onSelectGuise = async (guiseId: string) => {
    //     await mintWanderer(guiseId)
    // }


    return <section>
        <h3 className="m-10 text-2xl font-bold text-dark-200 ml-20">
            {'Select a Guise to Mint a New Wanderer'}
        </h3>

        <div className='flex justify-around items-center'>
            <div className='h-72 w-72'>
                <img src={testImg} alt="test"/>
            </div>
            <aside className='h-auto w-72 bg-dark-500 border border-dark-400'>
                <div className='h-auto m-2 p-2 flex justify-between items-center
                border border-dark-400 cursor-pointer hover:bg-dark-400'>
                    <p className=''>Choose skill</p>
                    <img src={plus} alt="plus" className='h-4 w-4'/>
                </div>
                <div className='h-auto m-2 p-2 flex justify-between items-center
                border border-dark-400 cursor-pointer hover:bg-dark-400'>
                    <p className=''>Choose skill</p>
                    <img src={plus} alt="plus" className='h-4 w-4'/>
                </div>
                <div className='h-auto m-2 p-2 flex justify-between items-center
                border border-dark-400 cursor-pointer hover:bg-dark-400'>
                    <p className=''>Choose skill</p>
                    <img src={plus} alt="plus" className='h-4 w-4'/>
                </div>
                <div className='h-auto m-2 p-2 flex justify-between items-center
                border border-dark-400 cursor-pointer hover:bg-dark-400'>
                    <p className=''>Choose skill</p>
                    <img src={plus} alt="plus" className='h-4 w-4'/>
                </div>
                <div className='h-auto m-2 p-2 flex justify-between items-center
                border border-dark-400 cursor-pointer hover:bg-dark-400'>
                    <p className=''>Choose skill</p>
                    <img src={plus} alt="plus" className='h-4 w-4'/>
                </div>

            </aside>
        </div>

    </section>
}