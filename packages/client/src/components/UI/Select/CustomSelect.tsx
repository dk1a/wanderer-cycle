import Select from "react-select";
import "./customSelect.scss";

export default function CustomSelect<T extends string | number>({
  options,
  placeholder,
  value,
  onChange,
}: {
  options: readonly { name: string; value: T }[];
  placeholder: string;
  value?: (getValue?: T) => void;
  onChange: (selectedValue?: T) => void;
}) {
  return (
    <Select
      classNamePrefix="custom-select"
      value={value}
      onChange={(event) => onChange(event.target.value as T | undefined)}
      options={options}
      placeholder={placeholder}
    >
      {/*<option disabled={true} value="">*/}
      {/*  {placeholder}*/}
      {/*</option>*/}
      {/*{options.map(({ name, value }) => (*/}
      {/*  <option key={name} value={value}>*/}
      {/*    {name}*/}
      {/*  </option>*/}
      {/*))}*/}
    </Select>
  );
}

// bg-dark-500 border border-dark-400 text-dark-200 text-sm h-8 w-36 focus:border-dark-string block w-56 mx-2
// dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:border-dark-comment
