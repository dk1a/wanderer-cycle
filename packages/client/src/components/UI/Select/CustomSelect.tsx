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
    ></Select>
  );
}
