// import { useContracts } from '../contexts/ContractsContext'
// import { useMintWanderer } from '../hooks/useWanderer'
// import Guise from '../components/Guise'
import Guise from "../../guise/Guise";

export default function WandererMint() {

    
    // //const [guiseId, setGuiseId] = useState('')
    // const { guiseList } = useContracts()
    // const { mintWanderer } = useMintWanderer()
    //
    // const onSelectGuise = async (guiseId: string) => {
    //     await mintWanderer(guiseId)
    // }


  return <section className='h-screen'>
    <hr className='h-px my-8 bg-gray-200 border-0 dark:bg-gray-700'/>
    <h3 className="m-10 text-2xl font-bold text-dark-200 ml-20">
        {'Select a Guise to Mint a New Wanderer'}
    </h3>

    <Guise id={1}/>

  </section>
}