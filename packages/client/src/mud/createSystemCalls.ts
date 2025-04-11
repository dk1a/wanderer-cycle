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

  const startCycle = async (
    wandererEntity: Hex,
    guiseEntity: Hex,
    wheelEntity: Hex,
  ) => {
    const tx = await worldContract.write.startCycle([
      wandererEntity,
      guiseEntity,
      wheelEntity,
    ]);
    await waitForTransaction(tx);
  };

  const cancelCycle = async (guiseEntity: Hex) => {
    const tx = await worldContract.write.cancelCycle([guiseEntity]);
    await waitForTransaction(tx);
  };

  const claimCycleTurns = async (cycleEntity: Hex) => {
    const tx = await worldContract.write.claimCycleTurns([cycleEntity]);
    await waitForTransaction(tx);
  };

  const passCycleTurn = async (cycleEntity: Hex) => {
    const tx = await worldContract.write.passTurn([cycleEntity]);
    await waitForTransaction(tx);
  };

  const learnCycleSkill = async (cycleEntity: Hex, skillEntity: Hex) => {
    const tx = await worldContract.write.learnSkill([cycleEntity, skillEntity]);
    await waitForTransaction(tx);
  };

  const activateCycleCombat = async (cycleEntity: Hex, mapEntity: Hex) => {
    const tx = await worldContract.write.activateCycleCombat([
      cycleEntity,
      mapEntity,
    ]);
    await waitForTransaction(tx);
  };

  const processCycleCombatRound = async (
    cycleEntity: Hex,
    action: CombatAction[],
  ) => {
    const tx = await worldContract.write.processCycleCombatRound([
      cycleEntity,
      action,
    ]);
    await waitForTransaction(tx);
  };

  const claimCycleCombatReward = async (
    cycleEntity: Hex,
    requestEntity: Hex,
  ) => {
    const tx = await worldContract.write.claimCycleCombatReward([
      cycleEntity,
      requestEntity,
    ]);
    await waitForTransaction(tx);
  };

  const cancelCycleCombatReward = async (
    cycleEntity: Hex,
    requestEntity: Hex,
  ) => {
    const tx = await worldContract.write.cancelCycleCombatReward([
      cycleEntity,
      requestEntity,
    ]);
    await waitForTransaction(tx);
  };

  // const permSkill = async (wandererEntity: Entity, skillEntity: Entity) => {
  //   const tx = await worldContract.write.PermSkill([wandererEntity as Hex, skillEntity as Hex]);
  //   await waitForTransaction(tx);
  // };

  const castNoncombatSkill = async (cycleEntity: Hex, skillEntity: Hex) => {
    const tx = await worldContract.write.castNoncombatSkill([
      cycleEntity,
      skillEntity,
    ]);
    await waitForTransaction(tx);
  };

  return {
    spawnWanderer,
    startCycle,
    cancelCycle,
    claimCycleTurns,
    passCycleTurn,
    learnCycleSkill,
    activateCycleCombat,
    processCycleCombatRound,
    claimCycleCombatReward,
    cancelCycleCombatReward,
    castNoncombatSkill,
    // permSkill,
  };
}
