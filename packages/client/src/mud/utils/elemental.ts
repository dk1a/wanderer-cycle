export enum StatmodElement {
  NONE,
  PHYSICAL,
  FIRE,
  COLD,
  POISON,
}

export interface Elemental {
  [StatmodElement.NONE]: number;
  [StatmodElement.PHYSICAL]: number;
  [StatmodElement.FIRE]: number;
  [StatmodElement.COLD]: number;
  [StatmodElement.POISON]: number;
}

export const parseElemental = (
  none: number,
  physical: number,
  fire: number,
  cold: number,
  poison: number,
): Elemental => {
  return {
    [StatmodElement.NONE]: none,
    [StatmodElement.PHYSICAL]: physical,
    [StatmodElement.FIRE]: fire,
    [StatmodElement.COLD]: cold,
    [StatmodElement.POISON]: poison,
  };
};

export const parseElementalArray = (
  damageArray: readonly number[],
): Elemental => {
  return {
    [StatmodElement.NONE]: damageArray[StatmodElement.NONE],
    [StatmodElement.PHYSICAL]: damageArray[StatmodElement.PHYSICAL],
    [StatmodElement.FIRE]: damageArray[StatmodElement.FIRE],
    [StatmodElement.COLD]: damageArray[StatmodElement.COLD],
    [StatmodElement.POISON]: damageArray[StatmodElement.POISON],
  };
};

export const statmodElements = [
  StatmodElement.NONE,
  StatmodElement.PHYSICAL,
  StatmodElement.FIRE,
  StatmodElement.COLD,
  StatmodElement.POISON,
] as const;

export const elementNames = {
  [StatmodElement.NONE]: "none",
  [StatmodElement.PHYSICAL]: "physical",
  [StatmodElement.FIRE]: "fire",
  [StatmodElement.COLD]: "cold",
  [StatmodElement.POISON]: "poison",
} as const;
