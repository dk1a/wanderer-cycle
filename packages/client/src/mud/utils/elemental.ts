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

export const statmodElements: StatmodElement[] = [
  StatmodElement.ALL,
  StatmodElement.COLD,
  StatmodElement.FIRE,
  StatmodElement.PHYSICAL,
  StatmodElement.POISON,
];

export const elementNames = {
  [StatmodElement.ALL]: "all",
  [StatmodElement.PHYSICAL]: "physical",
  [StatmodElement.FIRE]: "fire",
  [StatmodElement.COLD]: "cold",
  [StatmodElement.POISON]: "poison",
} as const;
