export enum StatmodElement {
  ALL,
  PHYSICAL,
  FIRE,
  COLD,
  POISON,
}

export interface Elemental {
  [StatmodElement.ALL]: number;
  [StatmodElement.PHYSICAL]: number;
  [StatmodElement.FIRE]: number;
  [StatmodElement.COLD]: number;
  [StatmodElement.POISON]: number;
}

export const parseElemental = (
  all: number,
  physical: number,
  fire: number,
  cold: number,
  poison: number
): Elemental => {
  return {
    [StatmodElement.ALL]: all,
    [StatmodElement.PHYSICAL]: physical,
    [StatmodElement.FIRE]: fire,
    [StatmodElement.COLD]: cold,
    [StatmodElement.POISON]: poison,
  };
};

export const statmodElements = [
  StatmodElement.ALL,
  StatmodElement.PHYSICAL,
  StatmodElement.FIRE,
  StatmodElement.COLD,
  StatmodElement.POISON,
] as const;

export const elementNames = {
  [StatmodElement.ALL]: "all",
  [StatmodElement.PHYSICAL]: "physical",
  [StatmodElement.FIRE]: "fire",
  [StatmodElement.COLD]: "cold",
  [StatmodElement.POISON]: "poison",
} as const;
