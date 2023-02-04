// import { useContracts } from '../contexts/ContractsContext'
// import { useMintWanderer } from '../hooks/useWanderer'
// import Guise from '../components/Guise'
import { useGuiseList } from '../../../mud/hooks/useGuiseList';
import testImg from '../../../utils/img/output.png'
import plus from '../../../utils/img/plus-square.svg'
import CustomButton from "../../../utils/UI/button/CustomButton";

export default function WandererMint() {
  const guiseList = useGuiseList();
  console.log(guiseList)
    
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

    <div className='h-96 w-80 border border-dark-400  p-8 flex flex-col justify-between items-center
    bg-dark-500 transform delay-500'>
      <img src={testImg} alt=""/>
      <CustomButton>Create</CustomButton>
    </div>

  </section>
}