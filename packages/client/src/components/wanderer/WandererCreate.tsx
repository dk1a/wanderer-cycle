import plus from '../../utils/img/plus-square.svg'
import {Link} from "react-router-dom";
const WandererCreate = () => {
    return (
        <Link to='/mint' className='border border-dark-400 w-80 h-auto p-8 flex flex-col justify-between items-center
        bg-dark-500'>
            <img src={plus} alt="question"/>
            <p className='text-dark-300'>Create a New Wanderer</p>
        </Link>
    );
};

export default WandererCreate;