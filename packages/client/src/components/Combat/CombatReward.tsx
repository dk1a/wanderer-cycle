import { useCallback, useState } from "react";
import { Hex } from "viem";
import { CycleCombatRewardRequest } from "../../mud/utils/combat";
import { useMUD } from "../../MUDContext";
import { Button } from "../utils/Button/Button";

const blockNumberLimit = 256;

export function CombatReward({
  requesterEntity,
  currentBlockNumber,
  rewardRequest,
}: {
  requesterEntity: Hex;
  currentBlockNumber: bigint;
  rewardRequest: CycleCombatRewardRequest;
}) {
  const { systemCalls } = useMUD();
  const [isBusy, setIsBusy] = useState(false);

  const { requestId, blocknumber: requestBlockNumber } = rewardRequest;

  const cancelCycleCombatReward = useCallback(async () => {
    setIsBusy(true);
    await systemCalls.cancelCycleCombatReward(requesterEntity, requestId);
    setIsBusy(false);
  }, [systemCalls, requesterEntity]);

  const claimCycleCombatReward = useCallback(async () => {
    setIsBusy(true);
    await systemCalls.claimCycleCombatReward(requesterEntity, requestId);
    setIsBusy(false);
  }, [systemCalls, requesterEntity]);

  const isExpired = currentBlockNumber - requestBlockNumber >= blockNumberLimit;

  if (isExpired) {
    return (
      <div className="flex flex-col items-center justify-around text-dark-200 text-lg">
        expired
        <Button
          style={{ width: "9rem" }}
          onClick={cancelCycleCombatReward}
          disabled={isBusy}
        >
          delete
        </Button>
      </div>
    );
  } else {
    return (
      <div className="flex flex-col items-center justify-around">
        {/* TODO make this a bar with small text above it, like experience */}
        <div className="text-dark-200 text-lg">
          expiring...
          <span className="text-dark-number ml-1">
            {currentBlockNumber - requestBlockNumber}
          </span>
          <span className="text-dark-200 mx-1">/</span>
          <span className="text-dark-number">{blockNumberLimit}</span>
        </div>
        <Button
          onClick={claimCycleCombatReward}
          style={{ width: "9rem" }}
          disabled={isBusy}
        >
          claim reward
        </Button>
      </div>
    );
  }
}
