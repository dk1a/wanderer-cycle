import { useCallback, useState } from "react";

export default function useToggle(initialValue: boolean) {
  const [value, setValue] = useState(initialValue);

  const toggle = useCallback(() => {
    setValue(!value);
  }, [setValue, value]);

  return [value, toggle];
}
