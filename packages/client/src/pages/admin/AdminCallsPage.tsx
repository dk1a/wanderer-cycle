import { useCallback, useState } from "react";
import { isHex } from "viem";
import { getRecord } from "@latticexyz/stash/internal";
import { mudTables, useStashCustom } from "../../mud/stash";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { Button } from "../../components/ui/Button";

export function AdminCallsPage() {
  const systemCalls = useSystemCalls();
  const [wandererEntity, setWandererEntity] = useState<string>("");

  const validWandererEntity = useStashCustom((state) => {
    if (!wandererEntity) return;
    if (!isHex(wandererEntity)) return;

    const wandererRecord = getRecord({
      state,
      table: mudTables.wanderer__Wanderer,
      key: { entity: wandererEntity },
    });

    if (wandererRecord?.value !== true) return;

    return wandererEntity;
  });

  const cycleEntity = useStashCustom((state) => {
    if (!validWandererEntity) return;

    return getRecord({
      state,
      table: mudTables.cycle__ActiveCycle,
      key: { entity: validWandererEntity },
    })?.cycleEntity;
  });

  const adminCompleteCycle = useCallback(async () => {
    if (!cycleEntity) throw new Error("No cycle entity");
    await systemCalls.admin.adminCompleteCycle(cycleEntity);
  }, [systemCalls, cycleEntity]);

  const [lootQuantity, setLootQuantity] = useState("5");
  const [lootTier, setLootTier] = useState("1");

  const adminMintLoot = useCallback(async () => {
    if (!cycleEntity) throw new Error("No cycle entity");
    const lootQuantityNumber = parseInt(lootQuantity);
    if (
      isNaN(lootQuantityNumber) ||
      lootQuantityNumber > 1000 ||
      lootQuantityNumber <= 0
    )
      throw new Error("Invalid loot quantity");
    const lootTierNumber = parseInt(lootTier);
    if (isNaN(lootTierNumber) || lootTierNumber > 4 || lootTierNumber <= 0)
      throw new Error("Invalid loot tier");
    await systemCalls.admin.adminMintLoot(
      cycleEntity,
      lootQuantityNumber,
      lootTierNumber,
    );
  }, [systemCalls, cycleEntity, lootQuantity, lootTier]);

  return (
    <section className="flex flex-col items-start gap-4 p-4">
      <div className="flex gap-2">
        <input
          className="custom-input"
          value={wandererEntity}
          onChange={(e) => setWandererEntity(e.target.value)}
          placeholder={"wandererEntity"}
        />

        <div>
          <span className="text-dark-key">valid: </span>
          <span className="text-dark-keyword">
            {validWandererEntity ? "true" : "false"}
          </span>
        </div>

        <div>
          <span className="text-dark-key">cycleEntity: </span>
          <span className="text-dark-keyword">{cycleEntity}</span>
        </div>
      </div>

      <Button onClick={adminCompleteCycle} disabled={!cycleEntity}>
        adminCompleteCycle
      </Button>

      <div>
        <input
          className="custom-input"
          type="number"
          value={lootQuantity}
          onChange={(e) => setLootQuantity(e.target.value)}
          placeholder={"lootQuantity"}
        />

        <input
          className="custom-input"
          type="number"
          value={lootTier}
          onChange={(e) => setLootTier(e.target.value)}
          placeholder={"lootTier"}
        />

        <Button onClick={adminMintLoot} disabled={!cycleEntity}>
          adminMintLoot
        </Button>
      </div>
    </section>
  );
}
