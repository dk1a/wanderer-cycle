import {
  ButtonHTMLAttributes,
  FC,
  useCallback,
  useMemo,
  useState,
} from "react";
import { useWandererContext } from "../../mud/WandererProvider";
import { useStashCustom } from "../../mud/stash";
import { getCycleTurns } from "../../mud/utils/turns";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { Button } from "../ui/Button";

type PassTurnButtonProps = Omit<
  ButtonHTMLAttributes<HTMLButtonElement>,
  "onClick"
>;

export const PassTurnButton: FC<PassTurnButtonProps> = (props) => {
  const { disabled, children, ...otherProps } = props;

  const systemCalls = useSystemCalls();
  const { cycleEntity, enemyEntity } = useWandererContext();

  const turns = useStashCustom((state) => getCycleTurns(state, cycleEntity));

  const [isBusy, setIsBusy] = useState(false);

  const passTurn = useCallback(async () => {
    if (cycleEntity === undefined) throw new Error("No cycle entity");
    setIsBusy(true);
    await systemCalls.cycle.passTurn(cycleEntity);
    setIsBusy(false);
  }, [systemCalls, cycleEntity]);

  const isComputedDisabled = useMemo(() => {
    // not available during combat (since it fully heals)
    const isEncounterActive = enemyEntity !== undefined;
    return !turns || isBusy || isEncounterActive;
  }, [turns, isBusy, enemyEntity]);

  return (
    <Button
      onClick={passTurn}
      disabled={isComputedDisabled || disabled}
      {...otherProps}
    >
      {children ?? "passTurn"}
    </Button>
  );
};
