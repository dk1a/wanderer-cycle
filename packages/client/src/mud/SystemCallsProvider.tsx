import { Hex } from "viem";
import { createContext, ReactNode, useContext, useMemo } from "react";
import { CombatAction } from "./utils/combat";
import { WorldContract } from "./useWorldContract";
import { SyncResult } from "@latticexyz/store-sync";

interface SystemCallsContextType {
  syncResult: SyncResult;

  spawnWanderer: (guiseEntity: Hex) => Promise<void>;
  permSkill: (wandererEntity: Hex, skillEntity: Hex) => Promise<void>;
  cycle: {
    startCycle: (
      wandererEntity: Hex,
      guiseEntity: Hex,
      wheelEntity: Hex,
    ) => Promise<void>;
    cancelCycle: (guiseEntity: Hex) => Promise<void>;
    completeCycle: (cycleEntity: Hex) => Promise<void>;
    adminCompleteCycle: (cycleEntity: Hex) => Promise<void>;
    claimTurns: (cycleEntity: Hex) => Promise<void>;
    passTurn: (cycleEntity: Hex) => Promise<void>;
    learnSkill: (cycleEntity: Hex, skillEntity: Hex) => Promise<void>;
    activateCombat: (cycleEntity: Hex, mapEntity: Hex) => Promise<void>;
    processCycleCombatRound: (
      cycleEntity: Hex,
      action: CombatAction[],
    ) => Promise<void>;
    claimCycleCombatReward: (
      cycleEntity: Hex,
      requestEntity: Hex,
    ) => Promise<void>;
    cancelCycleCombatReward: (
      cycleEntity: Hex,
      requestEntity: Hex,
    ) => Promise<void>;
    castNoncombatSkill: (cycleEntity: Hex, skillEntity: Hex) => Promise<void>;
    equip: (
      cycleEntity: Hex,
      slotEntity: Hex,
      equipmentEntity: Hex,
    ) => Promise<void>;
    unequip: (cycleEntity: Hex, slotEntity: Hex) => Promise<void>;
  };
  admin: {
    adminCompleteCycle: (cycleEntity: Hex) => Promise<void>;
    adminMintLoot: (
      cycleEntity: Hex,
      quantity: number,
      ilvl: number,
    ) => Promise<void>;
  };
}

const SystemCallsContext = createContext<SystemCallsContextType | undefined>(
  undefined,
);

export function SystemCallsProvider({
  syncResult,
  worldContract,
  children,
}: {
  syncResult: SyncResult;
  worldContract: WorldContract;
  children: ReactNode;
}) {
  const currentValue = useContext(SystemCallsContext);
  if (currentValue)
    throw new Error("SystemCallsProvider can only be used once");

  const value = useMemo((): SystemCallsContextType => {
    const waitForTransaction = syncResult.waitForTransaction;

    return {
      syncResult,

      spawnWanderer: async (guiseEntity: Hex) => {
        const tx = await worldContract.write.spawnWanderer([guiseEntity]);
        await waitForTransaction(tx);
      },

      permSkill: async (wandererEntity: Hex, skillEntity: Hex) => {
        const tx = await worldContract.write.permSkill([
          wandererEntity,
          skillEntity,
        ]);
        await waitForTransaction(tx);
      },

      cycle: {
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
          const tx = await worldContract.write.cycle__cancelCycle([
            guiseEntity,
          ]);
          await waitForTransaction(tx);
        },
        completeCycle: async (cycleEntity: Hex) => {
          const tx = await worldContract.write.cycle__completeCycle([
            cycleEntity,
          ]);
          await waitForTransaction(tx);
        },
        adminCompleteCycle: async (cycleEntity: Hex) => {
          const tx = await worldContract.write.cycle__adminCompleteCycle([
            cycleEntity,
          ]);
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
        claimCycleCombatReward: async (
          cycleEntity: Hex,
          requestEntity: Hex,
        ) => {
          const tx = await worldContract.write.cycle__claimCycleCombatReward([
            cycleEntity,
            requestEntity,
          ]);
          await waitForTransaction(tx);
        },
        cancelCycleCombatReward: async (
          cycleEntity: Hex,
          requestEntity: Hex,
        ) => {
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
        equip: async (
          cycleEntity: Hex,
          slotEntity: Hex,
          equipmentEntity: Hex,
        ) => {
          const tx = await worldContract.write.cycle__equip([
            cycleEntity,
            slotEntity,
            equipmentEntity,
          ]);
          await waitForTransaction(tx);
        },
        unequip: async (cycleEntity: Hex, slotEntity: Hex) => {
          const tx = await worldContract.write.cycle__unequip([
            cycleEntity,
            slotEntity,
          ]);
          await waitForTransaction(tx);
        },
      },
      admin: {
        adminCompleteCycle: async (cycleEntity: Hex) => {
          const tx = await worldContract.write.cycle__adminCompleteCycle([
            cycleEntity,
          ]);
          await waitForTransaction(tx);
        },
        adminMintLoot: async (
          cycleEntity: Hex,
          quantity: number,
          ilvl: number,
        ) => {
          const tx = await worldContract.write.cycle__adminMintLoot([
            cycleEntity,
            quantity,
            ilvl,
          ]);
          await waitForTransaction(tx);
        },
      },
    };
  }, [syncResult, worldContract]);

  return (
    <SystemCallsContext.Provider value={value}>
      {children}
    </SystemCallsContext.Provider>
  );
}

export function useSystemCalls() {
  const value = useContext(SystemCallsContext);
  if (!value) throw new Error("Must be used within a SystemCallsProvider");
  return value;
}
