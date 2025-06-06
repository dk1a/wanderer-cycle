import { useCallback } from "react";
import { Hex } from "viem";
import { useObservableValue } from "@latticexyz/react";
import { useWandererContext } from "../../mud/WandererProvider";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { useStashCustom } from "../../mud/stash";
import { getLifeCurrent } from "../../mud/utils/currents";
import {
  CombatResult,
  CycleCombatRewardLog,
  CycleCombatRewardRequest,
} from "../../mud/utils/combat";
import { CombatRewardRequest } from "../../components/combat/CombatRewardRequest";
import { CombatRewardLog } from "./CombatRewardLog";
import { Button } from "../../components/ui/Button";
import { PassTurnButton } from "../info/PassTurnButton";

interface CombatResultComponentProps {
  combatResult: CombatResult | undefined;
  mapEntity: Hex | undefined;
  combatRewardRequests: CycleCombatRewardRequest[];
  combatRewardLog: CycleCombatRewardLog | undefined;
  onCombatClose: () => void;
}

export function CombatResultComponent({
  combatResult,
  mapEntity,
  combatRewardRequests,
  combatRewardLog,
  onCombatClose,
}: CombatResultComponentProps) {
  const systemCalls = useSystemCalls();
  const { cycleEntity } = useWandererContext();

  const latestBlockNumber = useObservableValue(
    systemCalls.syncResult.latestBlockNumber$,
  );

  return (
    <div className="flex justify-around flex-col items-center w-1/3">
      {combatResult !== undefined && (
        <h3 className="text-center text-dark-string text-xl my-2">
          {CombatResult[combatResult]}
        </h3>
      )}

      <div>
        {cycleEntity !== undefined && latestBlockNumber !== undefined ? (
          combatRewardRequests.map((rewardRequest) => (
            <CombatRewardRequest
              key={rewardRequest.requestId}
              requesterEntity={cycleEntity}
              latestBlockNumber={latestBlockNumber}
              rewardRequest={rewardRequest}
            />
          ))
        ) : (
          <span>loading...</span>
        )}
      </div>

      {combatRewardLog && <CombatRewardLog combatRewardLog={combatRewardLog} />}

      <div className="flex justify-around w-full m-4">
        {cycleEntity && (
          <CombatRepeatOrRest
            playerEntity={cycleEntity}
            mapEntity={mapEntity}
          />
        )}

        {combatResult !== CombatResult.NONE &&
          combatRewardRequests.length === 0 && (
            <Button className="w-40" onClick={onCombatClose}>
              close
            </Button>
          )}
      </div>
    </div>
  );
}

interface CombatRepeatOrRestProps {
  playerEntity: Hex;
  mapEntity: Hex | undefined;
}

function CombatRepeatOrRest({
  playerEntity,
  mapEntity,
}: CombatRepeatOrRestProps) {
  const playerLifeCurrent = useStashCustom((state) =>
    getLifeCurrent(state, playerEntity),
  );
  const systemCalls = useSystemCalls();

  const onMapRepeat = useCallback(async () => {
    if (!mapEntity) throw new Error("No map entity");
    await systemCalls.cycle.activateCombat(playerEntity, mapEntity);
  }, [systemCalls, playerEntity, mapEntity]);

  if (playerLifeCurrent === undefined) return <></>;

  if (playerLifeCurrent === 0) {
    return <PassTurnButton className="w-40" />;
  } else if (mapEntity) {
    // TODO some things can't be repeated, add conditions
    return (
      <Button className="w-40" onClick={onMapRepeat}>
        repeat
      </Button>
    );
  }

  return <></>;
}
