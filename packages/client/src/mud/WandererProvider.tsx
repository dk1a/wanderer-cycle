import {
  createContext,
  ReactNode,
  useCallback,
  useContext,
  useEffect,
  useState,
} from "react";
import { Hex } from "viem";
import { useLocalStorage } from "usehooks-ts";
import { getRecord } from "@latticexyz/stash/internal";
import { mudTables, useStashCustom } from "./stash";
import { useSystemCalls } from "./SystemCallsProvider";
import { getLearnedSkillEntities } from "./utils/skill";
import { getCycleActiveCombat } from "./utils/combat";

type WandererContextType = {
  selectedWandererEntity?: Hex;
  selectWandererEntity: (wanderer: Hex | undefined) => void;
  cycleEntity?: Hex;
  cycleCombatEntity?: Hex;
  learnCycleSkill: (skillEntity: Hex) => Promise<void>;
  learnedSkillEntities: readonly Hex[];
  wandererMode: boolean;
  toggleWandererMode: () => void;
};

const WandererContext = createContext<WandererContextType | undefined>(
  undefined,
);

export function WandererProvider(props: { children: ReactNode }) {
  const currentValue = useContext(WandererContext);
  if (currentValue) throw new Error("WandererProvider can only be used once");

  // Save the selected wanderer entity in local storage
  const [selectedWandererEntity, selectWandererEntity] = useLocalStorage<
    Hex | undefined
  >("wanderer-cycle:wanderer:selectWandererEntity", undefined);
  // Clear local storage if chain state changed (mostly useful for local dev)
  const isWandererRecordAbsent = useStashCustom((state) => {
    if (!selectedWandererEntity) return false;
    const wandererRecord = getRecord({
      state,
      table: mudTables.wanderer__Wanderer,
      key: { entity: selectedWandererEntity },
    });
    return wandererRecord === undefined ? true : false;
  });
  useEffect(() => {
    if (isWandererRecordAbsent) {
      selectWandererEntity(undefined);
    }
  }, [isWandererRecordAbsent, selectWandererEntity]);

  // System calls
  const systemCalls = useSystemCalls();

  // current cycle
  const cycleEntity = useStashCustom((state) => {
    if (!selectedWandererEntity) return;

    return getRecord({
      state,
      table: mudTables.cycle__ActiveCycle,
      key: { entity: selectedWandererEntity },
    })?.cycleEntity;
  });

  // // previous cycle
  // const cyclePrevious = useMemo(() => {
  //   if (!selectedWandererEntity) {
  //     console.warn("No selected wanderer entity");
  //     return undefined;
  //   }
  //   return getComponentValueStrict(PreviousCycle, selectedWandererEntity);
  // }, [ActiveCycle, selectedWandererEntity]);
  // const previousCycleEntity = cyclePrevious?.toEntity as Entity | undefined;

  const cycleCombatEntity = useStashCustom((state) => {
    if (!cycleEntity) return;
    return getCycleActiveCombat(state, cycleEntity)?.combatEntity;
  });

  const learnCycleSkill = useCallback(
    async (skillEntity: Hex) => {
      if (cycleEntity === undefined) throw new Error("No cycle entity");
      await systemCalls.cycle.learnSkill(cycleEntity, skillEntity);
    },
    [systemCalls, cycleEntity],
  );
  const learnedSkillEntities = useStashCustom((state) => {
    if (!cycleEntity) return [];
    return getLearnedSkillEntities(state, cycleEntity);
  });

  const [wandererMode, setWandererMode] = useState(false);
  const toggleWandererMode = useCallback(
    () => setWandererMode((value) => !value),
    [],
  );

  const value = {
    selectedWandererEntity,
    selectWandererEntity,
    cycleEntity,
    cycleCombatEntity,
    learnCycleSkill,
    learnedSkillEntities,
    wandererMode,
    toggleWandererMode,
  };
  return (
    <WandererContext.Provider value={value}>
      {props.children}
    </WandererContext.Provider>
  );
}

export function useWandererContext() {
  const value = useContext(WandererContext);
  if (!value) throw new Error("Must be used within a WandererProvider");
  return value;
}
