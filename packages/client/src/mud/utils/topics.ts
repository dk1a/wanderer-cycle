export type StatmodTopic = (typeof statmodTopics)[number];

export const statmodTopics = [
  "life",
  "mana",
  "fortune",
  "connection",
  "life gained per turn",
  "mana gained per turn",
  "attack",
  "spell",
  "resistance",
  "damage taken per round",
  "damage taken",
  "reduced damage done",
  "rounds stunned",
  "% of missing life to {element} attack",
  "level",
] as const;
