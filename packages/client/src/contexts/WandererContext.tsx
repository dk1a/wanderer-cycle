import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { createContext, ReactNode, useCallback, useContext, useMemo, useState } from "react";
import {
  CycleCombatRewardRequest,
  OnCombatResultData,
  useActiveCombat,
  useCycleCombatRewardRequests,
  useOnCombatResultEffect,
} from "../mud/hooks/combat";
import { useLearnCycleSkill } from "../mud/hooks/skill";
import { useLearnedSkillEntities } from "../mud/hooks/skill";
import { useMUD } from "../mud/MUDContext";
import useToggle from "../utils/hooks/useToggle";
import { useLocalStorage } from "../utils/hooks/useLocalStorage";

type WandererContextType = {
  selectedWandererEntity: EntityIndex;
  selectWandererEntity: (wanderer: EntityIndex | undefined) => void;
  cycleEntity?: EntityIndex;
  previousCycleEntity?: EntityIndex;
  enemyEntity?: EntityIndex;
  combatRewardRequests: CycleCombatRewardRequest[];
  lastCombatResult?: OnCombatResultData;
  clearCombatResult: () => void;
  learnCycleSkill: ReturnType<typeof useLearnCycleSkill>;
  learnedSkillEntities: EntityIndex[];
  wandererMode: boolean;
  setWandererMode: () => void;
};

type WandererProviderType = {
  children: ReactNode;
  selectWandererEntity: (wanderer: EntityIndex | undefined) => void;
  selectedWandererEntity: EntityIndex | undefined;
};

const WandererContext = createContext<WandererContextType | undefined>(undefined);

export const WandererProvider = ({ children, selectWandererEntity, selectedWandererEntity }: WandererProviderType) => {
  const currentValue = useContext(WandererContext);
  if (currentValue) throw new Error("WandererProvider can only be used once");
  const {
    world,
    components: { ActiveCycle, ActiveCyclePrevious },
  } = useMUD();
  // current cycle
  const activeCycle = useComponentValue(ActiveCycle, selectedWandererEntity);
  const cycleEntity = useMemo(() => {
    return activeCycle?.value ? world.entityToIndex.get(activeCycle.value) : undefined;
  }, [activeCycle, world]);
  // previous cycle
  const activeCyclePrevious = useComponentValue(ActiveCyclePrevious, selectedWandererEntity);
  const previousCycleEntity = useMemo(() => {
    return activeCyclePrevious?.value ? world.entityToIndex.get(activeCyclePrevious.value) : undefined;
  }, [activeCyclePrevious, world]);

  const enemyEntity = useActiveCombat(cycleEntity);

  const combatRewardRequests = useCycleCombatRewardRequests(cycleEntity);
  const [lastCombatResult, setLastCombatResult] = useState<OnCombatResultData>();
  const clearCombatResult = useCallback(() => setLastCombatResult(undefined), []);
  useOnCombatResultEffect(cycleEntity, setLastCombatResult);

  const learnCycleSkill = useLearnCycleSkill(selectedWandererEntity);
  const learnedSkillEntities = useLearnedSkillEntities(cycleEntity);

  const [wandererMode, setWandererMode] = useToggle(false);

  const value = {
    selectedWandererEntity,
    selectWandererEntity,
    cycleEntity,
    previousCycleEntity,
    enemyEntity,
    combatRewardRequests,
    lastCombatResult,
    clearCombatResult,
    learnedSkillEntities,
    learnCycleSkill,
    wandererMode,
    setWandererMode,
  };
  return <WandererContext.Provider value={value}>{children}</WandererContext.Provider>;
};

export const useWandererContext = () => {
  const value = useContext(WandererContext);
  if (!value) throw new Error("Must be used within a WandererProvider");
  return value;
};
