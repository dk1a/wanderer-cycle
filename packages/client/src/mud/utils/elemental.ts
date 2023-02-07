export enum Element {
  ALL,
  PHYSICAL,
  FIRE,
  COLD,
  POISON,
}

export interface Elemental {
  all: number;
  physical: number;
  fire: number;
  cold: number;
  poison: number;
}

export const parseElemental = (
  all: number,
  physical: number,
  fire: number,
  cold: number,
  poison: number
): Elemental => {
  return {
    all,
    physical,
    fire,
    cold,
    poison,
  };
};

export const elementNames = {
  [Element.ALL]: "all",
  [Element.PHYSICAL]: "physical",
  [Element.FIRE]: "fire",
  [Element.COLD]: "cold",
  [Element.POISON]: "poison",
};
