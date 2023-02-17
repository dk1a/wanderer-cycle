const CustomSelect = ({ option, defaultValue, value, onChange }: any) => {
  return (
    <select
      className="
    bg-dark-400 border border-dark-comment text-dark-200 text-sm
    focus:border-dark-string block w-56 p-2.5 my-4
    dark:bg-gray-700
    dark:border-gray-600
    dark:placeholder-gray-400
    dark:text-white
    dark:focus:border-dark-comment"
      value={value}
      onChange={(event) => onChange(event.target.value)}
    >
      <option disabled={true} value="">
        {defaultValue}
      </option>
      {option.map((option) => (
        <option key={option.value} value={option.value}>
          {option.name}
        </option>
      ))}
    </select>
  );
};

export default CustomSelect;
