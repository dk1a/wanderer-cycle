enum ELE_STAT {
  NONE,
  PHYSICAL,
  FIRE,
  COLD,
  POISON,
}

enum SKILL_TYPE {
  COMBAT,
  NONCOMBAT,
  PASSIVE,
}

enum TARGET_TYPE {
  SELF,
  ENEMY,
  ALLY,
  SELF_OR_ALLY,
}

enum STATMOD_OP {
  ADD,
  MUL,
  BADD,
}

enum COMBAT_ACTION_TYPE {
  ATTACK,
  SKILL,
}

enum AFFIX_PART_ID {
  IMPLICIT,
  PREFIX,
  SUFFIX,
}

enum PSTAT {
  STRENGTH,
  ARCANA,
  DEXTERITY,
}

// Result for initiator; it's based on who loses all life first.
// This just indicates how the combat concluded.
enum COMBAT_RESULT {
  NONE,
  VICTORY,
  DEFEAT,
}

// TODO remove placeholder workaround if you find a better solution (eg make string[] work)
function getEnumKeys(enumObj: Record<string, number | string>): ["PH"] {
  // Filter the keys to remove the numeric ones, leaving only the string keys
  return Object.values(enumObj).filter((key) => isNaN(Number(key))) as ["PH"];
}

export function getEnumValues<O extends Record<string, number | string>>(enumObj: O): O[keyof O][] {
  return Object.values(enumObj).filter((key) => !isNaN(Number(key))) as never;
}

const PSTAT_ARRAY = getEnumKeys(PSTAT);
const ELE_STAT_ARRAY = getEnumKeys(ELE_STAT);
const SKILL_TYPE_ARRAY = getEnumKeys(SKILL_TYPE);
const TARGET_TYPE_ARRAY = getEnumKeys(TARGET_TYPE);
const STATMOD_OP_ARRAY = getEnumKeys(STATMOD_OP);
const AFFIX_PART_ID_ARRAY = getEnumKeys(AFFIX_PART_ID);
const COMBAT_ACTION_TYPE_ARRAY = getEnumKeys(COMBAT_ACTION_TYPE);
const COMBAT_RESULT_ARRAY = getEnumKeys(COMBAT_RESULT);

export {
  PSTAT,
  ELE_STAT,
  SKILL_TYPE,
  TARGET_TYPE,
  AFFIX_PART_ID,
  STATMOD_OP,
  COMBAT_ACTION_TYPE,
  COMBAT_RESULT,
  PSTAT_ARRAY,
  ELE_STAT_ARRAY,
  SKILL_TYPE_ARRAY,
  TARGET_TYPE_ARRAY,
  STATMOD_OP_ARRAY,
  AFFIX_PART_ID_ARRAY,
  COMBAT_ACTION_TYPE_ARRAY,
  COMBAT_RESULT_ARRAY,
};
