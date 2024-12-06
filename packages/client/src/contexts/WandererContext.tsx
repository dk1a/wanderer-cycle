import { createContext, ReactNode, useContext, useMemo, useState } from "react";
// import {
//   CycleCombatRewardRequest,
//   OnCombatResultData,
//   useActiveCombat,
//   useCycleCombatRewardRequests,
//   useOnCombatResultEffect,
// } from "../mud/hooks/combat";
// import { useLearnCycleSkill } from "../mud/hooks/skill";
// import { useLearnedSkillEntities } from "../mud/hooks/skill";
import { useMUD } from "../MUDContext";
import { Entity, getComponentValueStrict } from "@latticexyz/recs";

type WandererContextType = {
  selectedWandererEntity?: Entity;
  selectWandererEntity: (wanderer: Entity | undefined) => void;
  cycleEntity?: Entity;
  previousCycleEntity?: Entity;
  // enemyEntity?: Entity;
  // combatRewardRequests: CycleCombatRewardRequest[];
  // lastCombatResult?: OnCombatResultData;
  // clearCombatResult: () => void;
  // learnCycleSkill: ReturnType<typeof useLearnCycleSkill>;
  // learnedSkillEntities: Entity[];
  // wandererMode: boolean;
  // toggleWandererMode: () => void;
};

const WandererContext = createContext<WandererContextType | undefined>(
  undefined,
);

export const WandererProvider = (props: { children: ReactNode }) => {
  const currentValue = useContext(WandererContext);
  if (currentValue) throw new Error("WandererProvider can only be used once");

  const [selectedWandererEntity, selectWandererEntity] = useState<Entity>();

  const { components } = useMUD();
  const {
    ActiveCycle,
    // PreviousCycle
  } = components;

  // current cycle
  const activeCycle = useMemo(() => {
    if (!selectedWandererEntity) {
      console.warn("No selected wanderer entity");
      return undefined;
    }
    return getComponentValueStrict(ActiveCycle, selectedWandererEntity);
  }, [ActiveCycle, selectedWandererEntity]);
  const cycleEntity = activeCycle?.toEntity as Entity | undefined;

  // // previous cycle
  // const cyclePrevious = useMemo(() => {
  //   if (!selectedWandererEntity) {
  //     console.warn("No selected wanderer entity");
  //     return undefined;
  //   }
  //   return getComponentValueStrict(PreviousCycle, selectedWandererEntity);
  // }, [ActiveCycle, selectedWandererEntity]);
  // const previousCycleEntity = cyclePrevious?.toEntity as Entity | undefined;

  // const enemyEntity = useActiveCombat(cycleEntity);
  //
  // const combatRewardRequests = useCycleCombatRewardRequests(cycleEntity);
  // const [lastCombatResult, setLastCombatResult] = useState<OnCombatResultData>();
  // const clearCombatResult = useCallback(() => setLastCombatResult(undefined), []);
  // useOnCombatResultEffect(cycleEntity, setLastCombatResult);

  // const learnCycleSkill = useLearnCycleSkill(selectedWandererEntity);
  // const learnedSkillEntities = useLearnedSkillEntities(cycleEntity);

  // const [wandererMode, setWandererMode] = useState(false);
  // const toggleWandererMode = useCallback(() => setWandererMode((value) => !value), []);

  const value = {
    selectedWandererEntity,
    selectWandererEntity,
    cycleEntity,
    // previousCycleEntity,
    // enemyEntity,
    // combatRewardRequests,
    // lastCombatResult,
    // clearCombatResult,
    // learnedSkillEntities,
    // learnCycleSkill,
    // wandererMode,
    // toggleWandererMode,
  };
  return (
    <WandererContext.Provider value={value}>
      {props.children}
    </WandererContext.Provider>
  );
};

export const useWandererContext = () => {
  const value = useContext(WandererContext);
  if (!value) throw new Error("Must be used within a WandererProvider");
  return value;
};
