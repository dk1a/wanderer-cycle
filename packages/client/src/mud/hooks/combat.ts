import { useComponentValue } from "@latticexyz/react";
import {
  EntityID,
  EntityIndex,
  getComponentValue,
  getComponentValueStrict,
  Has,
  HasValue,
  setComponent,
} from "@latticexyz/recs";
import { BigNumber } from "ethers";
import { useCallback, useEffect, useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";
import { CombatAction } from "../utils/combat";
import { parsePStats } from "../utils/experience";

export const useActiveCombat = (entity: EntityIndex | undefined) => {
  const mud = useMUD();
  const {
    world,
    components: { ActiveCombat },
  } = mud;

  const activeCombat = useComponentValue(ActiveCombat, entity);
  const enemyEntity = useMemo(() => {
    const enemyEntityId = activeCombat?.value;
    if (!enemyEntityId) return;
    return world.entityToIndex.get(enemyEntityId);
  }, [world, activeCombat]);

  return enemyEntity;
};

export const useActivateCycleCombat = () => {
  const { world, systems } = useMUD();

  return useCallback(
    async (wandererEntity: EntityIndex, mapEntity: EntityIndex) => {
      const tx = await systems["system.CycleActivateCombat"].executeTyped(
        world.entities[wandererEntity],
        world.entities[mapEntity]
      );
      await tx.wait();
    },
    [world, systems]
  );
};

export const useExecuteCycleCombatRound = () => {
  const { world, systems } = useMUD();

  return useCallback(
    async (wandererEntity: EntityIndex, actions: CombatAction[]) => {
      const tx = await systems["system.CycleCombat"].executeTyped(world.entities[wandererEntity], actions);
      await tx.wait();
    },
    [world, systems]
  );
};

export const useClaimCycleCombatReward = () => {
  const { world, systems } = useMUD();

  return useCallback(
    async (wandererEntity: EntityIndex, requestEntity: EntityIndex) => {
      const tx = await systems["system.CycleCombatReward"].executeTyped(
        world.entities[wandererEntity],
        world.entities[requestEntity]
      );
      await tx.wait();
    },
    [world, systems]
  );
};

export const useCancelCycleCombatReward = () => {
  const { world, systems } = useMUD();

  return useCallback(
    async (wandererEntity: EntityIndex, requestEntity: EntityIndex) => {
      const tx = await systems["system.CycleCombatReward"].cancelRequest(
        world.entities[wandererEntity],
        world.entities[requestEntity]
      );
      await tx.wait();
    },
    [world, systems]
  );
};

export type CycleCombatRewardRequest = ReturnType<typeof useCycleCombatRewardRequests>[number];

export const useCycleCombatRewardRequests = (requesterEntity: EntityIndex | undefined) => {
  const mud = useMUD();
  const {
    world,
    components: { RNGRequestOwner, RNGPrecommit, CycleCombatRewardRequest },
  } = mud;

  const requesterEntityId = useMemo(() => {
    if (!requesterEntity) return;
    return world.entities[requesterEntity];
  }, [world, requesterEntity]);
  const requestEntities = useEntityQuery(
    [HasValue(RNGRequestOwner, { value: requesterEntityId }), Has(RNGPrecommit), Has(CycleCombatRewardRequest)],
    true
  );

  return useMemo(() => {
    return requestEntities.map((requestEntity) => {
      const precommit = getComponentValueStrict(RNGPrecommit, requestEntity).value;
      const request = getComponentValueStrict(CycleCombatRewardRequest, requestEntity);

      const mapEntity = world.entityToIndex.get(request.mapEntity);
      if (mapEntity === undefined) throw new Error(`No index for map entity id ${request.mapEntity}`);

      return {
        requestEntity,
        blocknumber: precommit,
        mapEntity,
        mapEntityId: request.mapEntity,
        connection: request.connection,
        fortune: request.fortune,
        winnerPStats: parsePStats(request.winner_strength, request.winner_arcana, request.winner_dexterity),
        loserPStats: parsePStats(request.loser_strength, request.loser_arcana, request.loser_dexterity),
      };
    });
  }, [world, RNGPrecommit, CycleCombatRewardRequest, requestEntities]);
};

export enum CombatResult {
  NONE,
  VICTORY,
  DEFEAT,
}

export interface OnCombatResultData {
  initiatorActions: CombatAction[];
  combatResult: CombatResult;
  enemyEntity: EntityIndex | undefined;
  cycleLifeDiff: number | undefined;
  enemyLifeDiff: number | undefined;
}

/**
 * Calls the callback after each CycleCombat system call with combat results as arguments
 * TODO replace this mess with action events
 */
export function useOnCombatResultEffect(
  // (But then this whole thing should be replaced with action events)
  initiatorEntity: EntityIndex | undefined,
  callback: (combatData: OnCombatResultData) => void
) {
  const {
    world,
    systemCallStreams,
    components: { ActiveCycle, ActiveCombat, LifeCurrent, _CombatLife },
  } = useMUD();

  useEffect(() => {
    const subscription1 = systemCallStreams["system.CycleActivateCombat"].subscribe((systemCall) => {
      if (initiatorEntity === undefined) return;
      const activeCombatUpdate = systemCall.updates.find(({ component }) => component.id === ActiveCombat.id);
      const cycleEntity = activeCombatUpdate?.entity as EntityIndex;
      if (initiatorEntity !== cycleEntity) return;
      const enemyEntityId = activeCombatUpdate?.value?.value as EntityID;
      const enemyEntity = world.entityToIndex.get(enemyEntityId);
      if (enemyEntity === undefined) return;

      setComponent(_CombatLife, cycleEntity, getComponentValueStrict(LifeCurrent, cycleEntity));
      setComponent(_CombatLife, enemyEntity, getComponentValueStrict(LifeCurrent, enemyEntity));
    });

    const subscription2 = systemCallStreams["system.CycleCombat"].subscribe((systemCall) => {
      if (initiatorEntity === undefined) return;
      const [wandererEntityBigNumber, initiatorActions] = systemCall.args as unknown as [BigNumber, CombatAction[]];
      const wandererEntity = world.entityToIndex.get(wandererEntityBigNumber.toHexString() as EntityID);
      if (wandererEntity === undefined) return;
      const cycleEntityId = getComponentValue(ActiveCycle, wandererEntity)?.value;
      const cycleEntity = cycleEntityId ? world.entityToIndex.get(cycleEntityId) : undefined;
      if (cycleEntity !== initiatorEntity) return;
      const enemyEntityId = getComponentValue(ActiveCombat, initiatorEntity)?.value;
      const enemyEntity = enemyEntityId ? world.entityToIndex.get(enemyEntityId) : undefined;

      const cycleLifeUpdate = systemCall.updates.find(
        ({ component, entity }) => component.id === LifeCurrent.id && entity === cycleEntity
      );
      const cycleLife = cycleLifeUpdate?.value?.value as number | undefined;
      const cycleLifePrev = getComponentValue(_CombatLife, cycleEntity)?.value;
      if (cycleLifeUpdate?.value !== undefined) setComponent(_CombatLife, cycleEntity, cycleLifeUpdate?.value);
      const cycleLifeDiff = cycleLifePrev !== undefined && cycleLife !== undefined ? cycleLife - cycleLifePrev : 0;

      const enemyLifeUpdate = systemCall.updates.find(
        ({ component, entity }) => component.id === LifeCurrent.id && entity === enemyEntity
      );
      const enemyLife = enemyLifeUpdate?.value?.value as number | undefined;
      const enemyLifePrev = enemyEntity === undefined ? undefined : getComponentValue(_CombatLife, enemyEntity)?.value;
      if (enemyLifeUpdate?.value !== undefined && enemyEntity !== undefined)
        setComponent(_CombatLife, enemyEntity, enemyLifeUpdate?.value);
      const enemyLifeDiff = enemyLifePrev !== undefined && enemyLife !== undefined ? enemyLife - enemyLifePrev : 0;

      let combatResult;
      if (enemyEntity !== undefined) {
        combatResult = CombatResult.NONE;
      } else {
        const lifeCurrent = getComponentValueStrict(LifeCurrent, initiatorEntity).value;
        combatResult = lifeCurrent === 0 ? CombatResult.DEFEAT : CombatResult.VICTORY;
      }

      callback({ initiatorActions, combatResult, enemyEntity, cycleLifeDiff, enemyLifeDiff });
    });
    return () => {
      subscription1.unsubscribe();
      subscription2.unsubscribe();
    };
  }, [world, ActiveCombat, ActiveCycle, LifeCurrent, _CombatLife, systemCallStreams, callback, initiatorEntity]);
}
