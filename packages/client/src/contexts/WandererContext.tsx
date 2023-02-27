import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { createContext, ReactNode, useContext, useMemo, useState } from "react";
import { CycleCombatRewardRequest, useActiveCombat, useCycleCombatRewardRequests } from "../mud/hooks/combat";
import { useLearnCycleSkill } from "../mud/hooks/skill";
import { useLearnedSkillEntities } from "../mud/hooks/skill";
import { useMUD } from "../mud/MUDContext";

type WandererContextType = {
  selectedWandererEntity?: EntityIndex;
  selectWandererEntity: (wanderer: EntityIndex | undefined) => void;
  cycleEntity?: EntityIndex;
  enemyEntity?: EntityIndex;
  combatRewardRequests: CycleCombatRewardRequest[];
  learnCycleSkill: ReturnType<typeof useLearnCycleSkill>;
  learnedSkillEntities: EntityIndex[];
};

const WandererContext = createContext<WandererContextType | undefined>(undefined);

export const WandererProvider = (props: { children: ReactNode }) => {
  const currentValue = useContext(WandererContext);
  if (currentValue) throw new Error("WandererProvider can only be used once");

  const [selectedWandererEntity, selectWandererEntity] = useState<EntityIndex>();
  const {
    world,
    components: { ActiveCycle },
  } = useMUD();

  const activeCycle = useComponentValue(ActiveCycle, selectedWandererEntity);
  const cycleEntity = useMemo(() => {
    return activeCycle?.value ? world.entityToIndex.get(activeCycle.value) : undefined;
  }, [activeCycle, world]);

  const enemyEntity = useActiveCombat(cycleEntity);

  const combatRewardRequests = useCycleCombatRewardRequests(cycleEntity);

  const learnCycleSkill = useLearnCycleSkill(selectedWandererEntity);
  const learnedSkillEntities = useLearnedSkillEntities(cycleEntity);

  const value = {
    selectedWandererEntity,
    selectWandererEntity,
    cycleEntity,
    enemyEntity,
    combatRewardRequests,
    learnedSkillEntities,
    learnCycleSkill,
  };
  return <WandererContext.Provider value={value}>{props.children}</WandererContext.Provider>;
};

export const useWandererContext = () => {
  const value = useContext(WandererContext);
  if (!value) throw new Error("Must be used within a WandererProvider");
  return value;
};
