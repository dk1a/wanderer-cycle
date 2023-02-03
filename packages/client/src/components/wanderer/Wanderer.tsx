
const Wanderer = ({children}: any) => {
    return (
        <div className='
        border border-dark-400
        w-80 h-auto p-8 flex flex-col justify-between items-center
        bg-dark-500 transform delay-500 '>
            {children}
        </div>
    );
};

export default Wanderer;