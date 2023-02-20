const CustomSelect = ({ option, defaultValue, value, onChange }: any) => {
  return (
    <select
      className="bg-dark-400 border border-dark-comment text-dark-200 text-sm h-8 w-36 focus:border-dark-string block w-56 mx-2
    dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:border-dark-comment"
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
