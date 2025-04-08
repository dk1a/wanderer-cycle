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

  const claimCycleTurns = async (wandererEntity: Hex) => {
    const tx = await worldContract.write.claimCycleTurns([wandererEntity]);
    await waitForTransaction(tx);
  };

  const passCycleTurn = async (wandererEntity: Hex) => {
    const tx = await worldContract.write.passCycleTurn([wandererEntity]);
    await waitForTransaction(tx);
  };

  const learnCycleSkill = async (wandererEntity: Hex, skillEntity: Hex) => {
    const tx = await worldContract.write.learnFromCycle([
      wandererEntity,
      skillEntity,
    ]);
    await waitForTransaction(tx);
  };

  const activateCycleCombat = async (wandererEntity: Hex, mapEntity: Hex) => {
    const tx = await worldContract.write.activateCycleCombat([
      wandererEntity,
      mapEntity,
    ]);
    await waitForTransaction(tx);
  };

  const cycleCombat = async (wandererEntity: Hex, action: CombatAction[]) => {
    const tx = await worldContract.write.processCycleCombatRound([
      wandererEntity,
      action,
    ]);
    await waitForTransaction(tx);
  };

  const claimCycleCombatReward = async (
    wandererEntity: Hex,
    requestEntity: Hex,
  ) => {
    const tx = await worldContract.write.claimCycleCombatReward([
      wandererEntity,
      requestEntity,
    ]);
    await waitForTransaction(tx);
  };

  const cancelCycleCombatReward = async (
    wandererEntity: Hex,
    requestEntity: Hex,
  ) => {
    const tx = await worldContract.write.cancelCycleCombatReward([
      wandererEntity,
      requestEntity,
    ]);
    await waitForTransaction(tx);
  };

  // const permSkill = async (wandererEntity: Entity, skillEntity: Entity) => {
  //   const tx = await worldContract.write.PermSkill([wandererEntity as Hex, skillEntity as Hex]);
  //   await waitForTransaction(tx);
  // };

  // const noncombatSkill = async (cycleEntity: Entity, skillEntity: Entity) => {
  //   const tx = await worldContract.write.NoncombatSkill([cycleEntity as Hex, skillEntity as Hex]);
  //   await waitForTransaction(tx);
  // };

  return {
    spawnWanderer,
    claimCycleTurns,
    passCycleTurn,
    learnCycleSkill,
    activateCycleCombat,
    cycleCombat,
    claimCycleCombatReward,
    cancelCycleCombatReward,
    // permSkill,
    // noncombatSkill
  };
}
