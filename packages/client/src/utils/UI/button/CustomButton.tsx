import {ReactNode} from "react";

type Props ={
    children: ReactNode,
    onClick: any
}
const CustomButton = ({children, onClick}: Props) => {
    return (
        <button onClick={onClick} className='
        p-2 pl-5 pr-5 transition-colors duration-700 transform
        bg-curiousBlue-800 hover:bg-curiousBlue-600
        text-gray-100 text-lg border border-curiousBlue-900'>
            {children}
        </button>
    );
};

export default CustomButton;