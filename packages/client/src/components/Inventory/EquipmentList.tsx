import { BigNumber } from "ethers";
import { useCallback, useEffect, useMemo, useState, Fragment } from "react";
import { useEquipmentContext } from "../../contexts/EquipmentContext";
import { useWalletsLootContext } from "../../contexts/WalletsLootContext";
import { useWandererContext } from "../../contexts/WandererContext";
import { useChangeEquipmentBatch } from "../../hooks/mutations/useChangeEquipmentBatch";
import { useGetCycleEquipment } from "../../hooks/queries/useGetCycleEquipment";
import { makeTokenData } from "../../utils/tokenBases";
import MethodButton from "../MethodButton";
import EquipmentItem from "./EquipmentItem";

export default function EquipmentList() {
  const { selectedWandererId, twAccount } = useWandererContext();
  const cycleEquipment = useGetCycleEquipment(selectedWandererId);
  const { isAvailable, getAllowedBases, accountEquipmentActions, equipmentDiff, unequip, restoreSlot } =
    useEquipmentContext();
  const changeEquipmentBatch = useChangeEquipmentBatch(selectedWandererId, accountEquipmentActions, isAvailable);

  // equipmentSlot -> tokenBase filter
  const [equipmentSlotFilter, setEquipmentSlotFilter] = useState<number>();
  const { tokenBaseFilter, setTokenBaseFilter } = useWalletsLootContext();

  useEffect(() => {
    setTokenBaseFilter(getAllowedBases(equipmentSlotFilter));
    return () => setTokenBaseFilter(undefined);
  }, [equipmentSlotFilter, getAllowedBases, setTokenBaseFilter]);

  const equipmentSlotFilterCallback = useCallback((equipmentSlot: number) => {
    setEquipmentSlotFilter((equipmentSlotFilter) => {
      if (equipmentSlot === equipmentSlotFilter) {
        return undefined;
      } else {
        return equipmentSlot;
      }
    });
  }, []);

  // commit equipment changes
  const onCommit = useCallback(() => {
    changeEquipmentBatch.writer.write?.();
  }, [changeEquipmentBatch]);

  // list of equipment slots, on-chain equipped items, and pending equip items
  const equipmentPairsList = useMemo(() => {
    if (!cycleEquipment.data || !twAccount) return;
    return cycleEquipment.data.map((equipmentItem) => {
      // actually equipped token (undefined if none are equipped))
      const tokenData = !equipmentItem.equippedTokenId.eq(0)
        ? makeTokenData(equipmentItem.equippedTokenId, twAccount, BigNumber.from(1))
        : undefined;
      // diff item can indicate a token to equip, or an unequip action
      const diffItem = equipmentDiff.find(({ equipSlot }) => BigNumber.from(equipSlot).eq(equipmentItem.equipmentSlot));
      // if fromAccount is null then this is an unequip action
      const diffTokenData =
        diffItem && diffItem.fromAccount !== null
          ? makeTokenData(BigNumber.from(diffItem.equipTokenId), diffItem.fromAccount, BigNumber.from(1))
          : undefined;
      // an unequip action leaves diffTokenData undefined
      const withDiffItem = !!diffItem;

      return {
        name: equipmentItem.name,
        equipmentSlot: equipmentItem.equipmentSlot,
        withDiffItem,
        tokenData,
        diffTokenData,
      };
    });
  }, [twAccount, cycleEquipment, equipmentDiff]);

  return (
    <section>
      <h4 className="text-center text-lg text-dark-type">Equipment</h4>

      <div>
        <span className="text-dark-comment">{`/* changes: ${equipmentDiff.length} */`}</span>

        {changeEquipmentBatch.enabled && (
          <MethodButton name="commit" className="ml-2" onClick={onCommit} disabled={changeEquipmentBatch.isBusy} />
        )}
      </div>

      <div className="grid grid-flow-dense grid-cols-2">
        {/* TODO mark a diffItem somehow?*/}
        {equipmentPairsList?.map(({ name, equipmentSlot, withDiffItem, tokenData, diffTokenData }, index) => {
          const colStart = index % 2 === 0 ? "col-start-1" : "col-start-2";
          const headerClass = `
          ${colStart}
          flex-grow box-border w-48 mt-2 pl-2 gap-x-1
          border border-dark-400 border-b-0
          ${withDiffItem ? "bg-dark-500" : ""}
        `;
          return (
            <Fragment key={equipmentSlot}>
              {/*<div key={equipmentSlot} className="flex flex-col">*/}
              <div className={headerClass}>
                <h4
                  className="text-dark-control cursor-pointer flex-grow"
                  onClick={() => equipmentSlotFilterCallback(equipmentSlot)}
                >
                  {name}

                  {equipmentSlot === equipmentSlotFilter && <span className="text-dark-200 ml-1">(filtered)</span>}
                </h4>

                {withDiffItem && <MethodButton name="restoreSlot" onClick={() => restoreSlot(equipmentSlot)} />}
                {!withDiffItem && !diffTokenData && tokenData && (
                  <MethodButton name="unequip" onClick={() => unequip(equipmentSlot)} />
                )}
              </div>

              {!withDiffItem && tokenData ? (
                <EquipmentItem tokenData={tokenData} className={colStart} />
              ) : withDiffItem && diffTokenData ? (
                <EquipmentItem tokenData={diffTokenData} className={colStart} />
              ) : (
                <div className={`${colStart} border-t border-dark-400`}></div>
              )}
            </Fragment>
          );
        })}
      </div>
    </section>
  );
}
