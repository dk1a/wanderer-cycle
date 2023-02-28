export enum Element {
  ALL,
  PHYSICAL,
  FIRE,
  COLD,
  POISON,
}

export interface Elemental {
  [Element.ALL]: number;
  [Element.PHYSICAL]: number;
  [Element.FIRE]: number;
  [Element.COLD]: number;
  [Element.POISON]: number;
}

export const parseElemental = (
  all: number,
  physical: number,
  fire: number,
  cold: number,
  poison: number
): Elemental => {
  return {
    [Element.ALL]: all,
    [Element.PHYSICAL]: physical,
    [Element.FIRE]: fire,
    [Element.COLD]: cold,
    [Element.POISON]: poison,
  };
};

export const elementNames = {
  [Element.ALL]: "all",
  [Element.PHYSICAL]: "physical",
  [Element.FIRE]: "fire",
  [Element.COLD]: "cold",
  [Element.POISON]: "poison",
} as const;
