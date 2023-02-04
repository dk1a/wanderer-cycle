import { createContext, ReactNode, useContext, useState } from "react";

type WandererContextType = {
  selectedWandererEntity?: string,
  selectWandererEntity: (wanderer: string) => void,
};

const WandererContext = createContext<WandererContextType>({
  selectWandererEntity: () => {},
});

export const WandererProvider = (props: { children: ReactNode }) => {
  const currentValue = useContext(WandererContext);
  if (currentValue) throw new Error("WandererProvider can only be used once");

  const [selectedWandererEntity, selectWandererEntity] = useState<string>()

  const value = {
    selectedWandererEntity, selectWandererEntity,
  }
  return <WandererContext.Provider value={value}>{props.children}</WandererContext.Provider>;
};

export const useWandererContext = () => {
  const value = useContext(WandererContext);
  if (!value) throw new Error("Must be used within a WandererProvider");
  return value;
};
