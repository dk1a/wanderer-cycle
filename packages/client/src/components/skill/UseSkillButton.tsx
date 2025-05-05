import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import { getSkill, getSkillCooldown } from "../../mud/utils/skill";
import { getManaCurrent } from "../../mud/utils/currents";
import { Button } from "../ui/Button";

type UseSkillButtonData = {
  userEntity: Hex | undefined;
  skillEntity: Hex | undefined;
  onSkill: () => Promise<void>;
  disabled?: boolean;
};

export function UseSkillButton({
  userEntity,
  skillEntity,
  onSkill,
  disabled,
}: UseSkillButtonData) {
  disabled ??= false;

  const skill = useStashCustom((state) => {
    if (!skillEntity) return;
    return getSkill(state, skillEntity);
  });
  const cooldown = useStashCustom((state) => {
    if (!userEntity || !skillEntity) return;
    return getSkillCooldown(state, userEntity, skillEntity);
  });
  const manaCurrent = useStashCustom((state) =>
    getManaCurrent(state, userEntity),
  );

  return (
    <div className="flex items-center justify-center">
      <Button
        onClick={onSkill}
        disabled={
          disabled ||
          userEntity === undefined ||
          skill === undefined ||
          manaCurrent === undefined ||
          manaCurrent <= skill.cost ||
          (cooldown !== undefined && cooldown.timeValue > 0)
        }
      >
        use skill
      </Button>
      {cooldown !== undefined && cooldown.timeValue > 0 && (
        <div className="ml-2">
          (<span className="text-dark-number">{cooldown.timeValue} </span>
          <span className="text-dark-string">{cooldown.timeId}</span>)
        </div>
      )}
    </div>
  );
}
