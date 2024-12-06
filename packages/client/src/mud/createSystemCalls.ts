/*
 * Create the system calls that the client can use to ask
 * for changes in the World state (using the System contracts).
 */
import { Hex } from "viem";
import { Entity } from "@latticexyz/recs";

import { SetupNetworkResult } from "./setupNetwork";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  /*
   * The parameter list informs TypeScript that:
   *
   * - The first parameter is expected to be a
   *   SetupNetworkResult, as defined in setupNetwork.ts
   *
   *   Out of this parameter, we only care about two fields:
   *   - worldContract (which comes from getContract, see
   *     https://github.com/latticexyz/mud/blob/main/templates/react/packages/client/src/mud/setupNetwork.ts#L63-L69).
   *
   *   - waitForTransaction (which comes from syncToRecs, see
   *     https://github.com/latticexyz/mud/blob/main/templates/react/packages/client/src/mud/setupNetwork.ts#L77-L83).
   *
   * - From the second parameter, which is a ClientComponent,
   *   we only care about Counter. This parameter comes to use
   *   through createClientComponents.ts, but it originates in
   *   syncToRecs
   *   (https://github.com/latticexyz/mud/blob/main/templates/react/packages/client/src/mud/setupNetwork.ts#L77-L83).
   */
  { worldContract, waitForTransaction }: SetupNetworkResult,
) {
  const spawnWanderer = async (guiseEntity: Entity) => {
    const tx = await worldContract.write.spawnWanderer([guiseEntity as Hex]);
    await waitForTransaction(tx);
  };

  // const learnCycleSkill = async (wandererEntity: Entity, skillEntity: Entity) => {
  //   const tx = await worldContract.write.LearnCycleSkill([wandererEntity as Hex, skillEntity as Hex]);
  //   await waitForTransaction(tx);
  // };

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
    // learnCycleSkill,
    // permSkill,
    // noncombatSkill
  };
}
