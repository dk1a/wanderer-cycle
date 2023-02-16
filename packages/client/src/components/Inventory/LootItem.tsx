import { TokenData } from "../../utils/tokenBases";
import { useMemo } from "react";
import { checkTokenBase } from "../../utils/ERC1155SplitId";
import { TokenBases } from "../../utils/tokenBases";
import BaseLootItem from "./BaseLootItem";
import { useIdentifyLoot } from "../../hooks/mutations/useIdentifyLoot";
import { useGetLootState } from "../../hooks/queries/useGetLootState";
import MethodButton from "../MethodButton";
import { BigNumber } from "ethers";
import { useEquipmentContext } from "../../contexts/EquipmentContext";
import { useChangeEquipmentBatch } from "../../hooks/mutations/useChangeEquipmentBatch";
import { useUriJson } from "../../hooks/uri/useUriJson";

export default function LootItem({ tokenData }: { tokenData: TokenData }) {
  const json = useUriJson(tokenData.tokenId);

  // identification button
  const lootState = useGetLootState(tokenData.account);
  const identifyLoot = useIdentifyLoot();
  const identifyButton = useMemo(() => {
    const isAvailable = checkTokenBase(tokenData.tokenId, TokenBases.LOOT_UNIDENTIFIED);
    const isDisabled = !identifyLoot.enabled || !lootState.data?.canIdentify;
    return {
      isAvailable,
      isDisabled,
      callback: () => {
        if (!isAvailable || isDisabled) throw new Error("identifyCallback is not available");
        let amount: BigNumber = tokenData.balance;
        // request manual amount for multiple tokens
        if (amount.gt(1)) {
          const input = window.prompt("Amount to identify:", amount.toString());
          if (input === null) return;
          const inputInt = parseInt(input);
          if (isNaN(inputInt) || !isFinite(inputInt) || inputInt <= 0) {
            window.alert("Invalid amount");
            return;
          }
          amount = BigNumber.from(inputInt);
          if (amount.gt(tokenData.balance)) {
            window.alert("Amount is greater than balance");
            return;
          }
        }
        // identify
        identifyLoot.write({
          recklesslySetUnpreparedArgs: [tokenData.account, [tokenData.tokenId], [amount]],
        });
      },
    };
  }, [tokenData, identifyLoot, lootState]);

  // equipment buttons
  const {
    isAvailable: isEquipmentAvailable,
    equipmentDiff,
    getAllowedSlots,
    equip,
    restoreSlot,
  } = useEquipmentContext();
  // TODO check that this is how it even works, do these hooks share isLoading state regardless of args?
  // buttons are disabled while stuff is loading
  const changeEquipmentBatch = useChangeEquipmentBatch(undefined, undefined, false);
  const isEquipmentDisabled = useMemo(() => {
    return !isEquipmentAvailable || changeEquipmentBatch.writer.isLoading;
  }, [isEquipmentAvailable, changeEquipmentBatch]);
  // whether token is already being equipped
  const diffItem = useMemo(() => {
    return equipmentDiff.find(
      ({ fromAccount, equipTokenId }) => tokenData.account === fromAccount && tokenData.tokenId.eq(equipTokenId)
    );
  }, [equipmentDiff, tokenData]);
  // equip
  const equipButtons = useMemo(() => {
    if (diffItem) return [];
    const allowedSlots = getAllowedSlots(tokenData.tokenBase);
    if (!allowedSlots) return [];

    return allowedSlots.map(({ equipmentSlot, name }) => ({
      isDisabled: isEquipmentDisabled,
      name,
      callback: () => {
        if (isEquipmentDisabled) throw new Error("equip callback is not available");
        equip(equipmentSlot, tokenData.tokenId, tokenData.account);
      },
    }));
  }, [isEquipmentDisabled, diffItem, tokenData, getAllowedSlots, equip]);
  // restoreSlot
  const restoreSlotButton = useMemo(() => {
    const isAvailable = !!diffItem;
    return {
      isAvailable,
      isDisabled: isEquipmentDisabled,
      callback: () => {
        if (isEquipmentDisabled || !diffItem) throw new Error("restoreSlot callback is not available");
        restoreSlot(diffItem.equipSlot);
      },
    };
  }, [isEquipmentDisabled, diffItem, restoreSlot]);

  const children = (
    <>
      {identifyButton.isAvailable && (
        <MethodButton name="identify" disabled={identifyButton.isDisabled} onClick={identifyButton.callback} />
      )}
      {equipButtons.map(({ isDisabled, name, callback }) => (
        <MethodButton name="equip" key={`equip_${name}`} args={[name]} disabled={isDisabled} onClick={callback} />
      ))}
      {restoreSlotButton.isAvailable && (
        <MethodButton name="restoreSlot" disabled={restoreSlotButton.isDisabled} onClick={restoreSlotButton.callback} />
      )}
    </>
  );

  return BaseLootItem({ tokenData, showSymbol: true, json: json.data, children });
}
