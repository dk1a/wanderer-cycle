import { useState, useEffect } from "react";

type LocalStorageData = {
  initialValue: any;
  key: string;
};
function useLocalStorage(initialValue, key): LocalStorageData {
  const getValue = () => {
    const storage = localStorage.getItem(key);

    if (storage) {
      return JSON.parse(storage);
    }

    return initialValue;
  };

  const [value, setValue] = useState(getValue);

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [value, key]);

  return [value, setValue];
}

export { useLocalStorage };
