import { EntityIndex } from "@latticexyz/recs";
import { BigNumber } from "ethers";
import {
  CycleCombatRewardRequest,
  useCancelCycleCombatReward,
  useClaimCycleCombatReward,
} from "../../mud/hooks/combat";
import CustomButton from "../UI/Button/CustomButton";
import { PStatWithProgress } from "../info/PStatWithProgress";
import ProgressBar from "../UI/Progressbar/ProgressBar";

const blockNumberLimit = 256;

export function CombatReward({
  requesterEntity,
  currentBlockNumber,
  rewardRequest,
}: {
  requesterEntity: EntityIndex;
  currentBlockNumber: number;
  rewardRequest: CycleCombatRewardRequest;
}) {
  const claimCycleCombatReward = useClaimCycleCombatReward();
  const cancelCycleCombatReward = useCancelCycleCombatReward();
  const { requestEntity, blocknumber } = rewardRequest;
  const requestBlockNumber = BigNumber.from(blocknumber).toNumber();

  const isExpired = currentBlockNumber - requestBlockNumber >= blockNumberLimit;

  if (isExpired) {
    return (
      <div className="flex flex-col items-center justify-around border border-dark-400 p-2 w-56 h-24">
        expired
        <CustomButton onClick={() => cancelCycleCombatReward(requesterEntity, requestEntity)}>delete</CustomButton>
      </div>
    );
  } else {
    return (
      <div className="flex flex-col items-center justify-around w-56 h-24">
        <div className="text-dark-200 text-lg">
          expiring...
          <span className="text-dark-number ml-1">{currentBlockNumber - requestBlockNumber}</span>
          <span className="text-dark-200 mx-1">/</span>
          <span className="text-dark-number">{blockNumberLimit}</span>
        </div>
        <ProgressBar total={blockNumberLimit} start={currentBlockNumber - requestBlockNumber} />
        <CustomButton onClick={() => claimCycleCombatReward(requesterEntity, requestEntity)}>claim reward</CustomButton>
      </div>
    );
  }
}
