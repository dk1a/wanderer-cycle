import { EntityIndex } from "@latticexyz/recs";
import { BigNumber } from "ethers";
import { CycleCombatRewardRequest, useClaimCycleCombatReward } from "../../mud/hooks/combat";
import CustomButton from "../UI/Button/CustomButton";

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
  const { requestEntity, blocknumber } = rewardRequest;
  const requestBlockNumber = BigNumber.from(blocknumber).toNumber();

  const isExpired = currentBlockNumber - requestBlockNumber >= blockNumberLimit;

  if (isExpired) {
    return (
      <div>
        expired
        <CustomButton onClick={() => console.log("TODO add expired reward deletion")}>delete</CustomButton>
      </div>
    );
  } else {
    return (
      <div>
        <CustomButton key={requestEntity} onClick={() => claimCycleCombatReward(requesterEntity, requestEntity)}>
          claim reward
        </CustomButton>

        {/* TODO make this a bar with small text above it, like experience */}
        <div>
          expiring...
          {currentBlockNumber - requestBlockNumber} / {blockNumberLimit}
        </div>
      </div>
    );
  }
}
