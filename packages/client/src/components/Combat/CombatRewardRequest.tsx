import { useCallback, useMemo, useState } from "react";
import { Hex } from "viem";
import { CycleCombatRewardRequest } from "../../mud/utils/combat";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { Button } from "../ui/Button";

const blockNumberLimit = 256;

export function CombatRewardRequest({
  requesterEntity,
  latestBlockNumber,
  rewardRequest,
}: {
  requesterEntity: Hex;
  latestBlockNumber: bigint;
  rewardRequest: CycleCombatRewardRequest;
}) {
  const systemCalls = useSystemCalls();
  const [isBusy, setIsBusy] = useState(false);

  const { requestId, blocknumber: requestBlockNumber } = rewardRequest;

  const cancelCycleCombatReward = useCallback(async () => {
    setIsBusy(true);
    await systemCalls.cycle.cancelCycleCombatReward(requesterEntity, requestId);
    setIsBusy(false);
  }, [systemCalls, requesterEntity, requestId]);

  const claimCycleCombatReward = useCallback(async () => {
    setIsBusy(true);
    await systemCalls.cycle.claimCycleCombatReward(requesterEntity, requestId);
    setIsBusy(false);
  }, [systemCalls, requesterEntity, requestId]);

  const { isExpired, relProgress } = useMemo(() => {
    const blockNumberDiff = latestBlockNumber - requestBlockNumber;

    return {
      isExpired: blockNumberDiff >= blockNumberLimit,
      relProgress: Number(
        (100n * blockNumberDiff) / BigInt(blockNumberLimit),
      ).toFixed(0),
    };
  }, [latestBlockNumber, requestBlockNumber]);

  if (isExpired) {
    return (
      <div className="flex flex-col items-center justify-around text-dark-200 text-lg">
        expired
        <Button
          className="w-40"
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
        <div className="text-lg">
          expiring...
          <span className="text-dark-number ml-1">
            {(latestBlockNumber - requestBlockNumber).toString()}
          </span>
          <span> / </span>
          <span className="text-dark-number">{blockNumberLimit}</span>
        </div>

        <div className="w-full flex h-1 bg-dark-400 mb-2">
          <div
            className="bg-dark-300"
            style={{ width: `${relProgress}%` }}
          ></div>
        </div>

        <Button
          className="w-40"
          onClick={claimCycleCombatReward}
          disabled={isBusy}
        >
          claimReward
        </Button>
      </div>
    );
  }
}
