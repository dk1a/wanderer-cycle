import { SyncStep } from "@latticexyz/store-sync";
import { initialProgress, SyncProgress } from "@latticexyz/store-sync/internal";
import { getRecord } from "@latticexyz/stash/internal";
import { StateLocal } from "./stash";

export function getSyncStatus(state: StateLocal) {
  const progress = getRecord({
    state,
    table: SyncProgress,
    key: {},
    defaultValue: initialProgress,
  });
  return {
    ...progress,
    isLive: progress.step === SyncStep.LIVE,
  };
}
