/*
 * Create the system calls that the client can use to ask
 * for changes in the World state (using the System contracts).
 */
import { Hex } from "viem";

import { SetupNetworkResult } from "./setupNetwork";
import { CombatAction } from "./utils/combat";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls({
  worldContract,
  waitForTransaction,
}: SetupNetworkResult) {
  const spawnWanderer = async (guiseEntity: Hex) => {
    const tx = await worldContract.write.spawnWanderer([guiseEntity]);
    await waitForTransaction(tx);
  };

  const cycle = {
    startCycle: async (
      wandererEntity: Hex,
      guiseEntity: Hex,
      wheelEntity: Hex,
    ) => {
      const tx = await worldContract.write.cycle__startCycle([
        wandererEntity,
        guiseEntity,
        wheelEntity,
      ]);
      await waitForTransaction(tx);
    },
    cancelCycle: async (guiseEntity: Hex) => {
      const tx = await worldContract.write.cycle__cancelCycle([guiseEntity]);
      await waitForTransaction(tx);
    },
    claimTurns: async (cycleEntity: Hex) => {
      const tx = await worldContract.write.cycle__claimTurns([cycleEntity]);
      await waitForTransaction(tx);
    },
    passTurn: async (cycleEntity: Hex) => {
      const tx = await worldContract.write.cycle__passTurn([cycleEntity]);
      await waitForTransaction(tx);
    },
    learnSkill: async (cycleEntity: Hex, skillEntity: Hex) => {
      const tx = await worldContract.write.cycle__learnSkill([
        cycleEntity,
        skillEntity,
      ]);
      await waitForTransaction(tx);
    },
    activateCombat: async (cycleEntity: Hex, mapEntity: Hex) => {
      const tx = await worldContract.write.cycle__activateCombat([
        cycleEntity,
        mapEntity,
      ]);
      await waitForTransaction(tx);
    },
    processCycleCombatRound: async (
      cycleEntity: Hex,
      action: CombatAction[],
    ) => {
      const tx = await worldContract.write.cycle__processCycleCombatRound([
        cycleEntity,
        action,
      ]);
      await waitForTransaction(tx);
    },
    claimCycleCombatReward: async (cycleEntity: Hex, requestEntity: Hex) => {
      const tx = await worldContract.write.cycle__claimCycleCombatReward([
        cycleEntity,
        requestEntity,
      ]);
      await waitForTransaction(tx);
    },
    cancelCycleCombatReward: async (cycleEntity: Hex, requestEntity: Hex) => {
      const tx = await worldContract.write.cycle__cancelCycleCombatReward([
        cycleEntity,
        requestEntity,
      ]);
      await waitForTransaction(tx);
    },
    castNoncombatSkill: async (cycleEntity: Hex, skillEntity: Hex) => {
      const tx = await worldContract.write.cycle__castNoncombatSkill([
        cycleEntity,
        skillEntity,
      ]);
      await waitForTransaction(tx);
    },
  };

  // const permSkill = async (wandererEntity: Entity, skillEntity: Entity) => {
  //   const tx = await worldContract.write.PermSkill([wandererEntity as Hex, skillEntity as Hex]);
  //   await waitForTransaction(tx);
  // };

  return {
    spawnWanderer,
    cycle,
    // permSkill,
  };
}
