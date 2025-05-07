import { ELE_STAT } from "contracts/enums";

export interface Elemental {
  [ELE_STAT.NONE]: number;
  [ELE_STAT.PHYSICAL]: number;
  [ELE_STAT.FIRE]: number;
  [ELE_STAT.COLD]: number;
  [ELE_STAT.POISON]: number;
}

export function parseElemental(
  none: number,
  physical: number,
  fire: number,
  cold: number,
  poison: number,
): Elemental {
  return {
    [ELE_STAT.NONE]: none,
    [ELE_STAT.PHYSICAL]: physical,
    [ELE_STAT.FIRE]: fire,
    [ELE_STAT.COLD]: cold,
    [ELE_STAT.POISON]: poison,
  };
}

export function parseElementalArray(array: readonly number[]): Elemental {
  return {
    [ELE_STAT.NONE]: array[ELE_STAT.NONE],
    [ELE_STAT.PHYSICAL]: array[ELE_STAT.PHYSICAL],
    [ELE_STAT.FIRE]: array[ELE_STAT.FIRE],
    [ELE_STAT.COLD]: array[ELE_STAT.COLD],
    [ELE_STAT.POISON]: array[ELE_STAT.POISON],
  };
}

export const eleStatNames = {
  [ELE_STAT.NONE]: "none",
  [ELE_STAT.PHYSICAL]: "physical",
  [ELE_STAT.FIRE]: "fire",
  [ELE_STAT.COLD]: "cold",
  [ELE_STAT.POISON]: "poison",
} as const;

export const eleStatColorClasses = {
  [ELE_STAT.NONE]: "",
  [ELE_STAT.PHYSICAL]: "text-dark-200",
  [ELE_STAT.FIRE]: "text-red-200",
  [ELE_STAT.COLD]: "text-blue-200",
  [ELE_STAT.POISON]: "text-green-200",
} as const;
