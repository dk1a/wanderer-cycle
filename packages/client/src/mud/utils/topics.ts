export type StatmodTopic = (typeof statmodTopics)[number];
export type ElementalStatmodTopic = (typeof elementalStatmodTopics)[number];

export const statmodTopics = [
  "strength",
  "arcana",
  "dexterity",

  "life",
  "mana",
  "fortune",
  "connection",
  "life gained per turn",
  "mana gained per turn",

  "damage taken",
  "reduced damage done",
  "rounds stunned",

  "level",
] as const;

export const elementalStatmodTopics = [
  "attack",
  "spell",
  "resistance",

  "damage taken per round",

  "% of missing life to {element} attack",
] as const;
