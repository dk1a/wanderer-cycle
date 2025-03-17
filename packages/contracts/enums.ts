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

// TODO remove placeholder workaround if you find a better solution (eg make string[] work)
function getEnumNames(enumObj: Record<string, number | string>): ["PH"] {
  // Filter the keys to remove the numeric ones, leaving only the string keys
  return Object.keys(enumObj).filter((key) => isNaN(Number(key))) as ["PH"];
}

const PSTAT_ARRAY = getEnumNames(PSTAT);
const ELE_STAT_ARRAY = getEnumNames(ELE_STAT);
const SKILL_TYPE_ARRAY = getEnumNames(SKILL_TYPE);
const TARGET_TYPE_ARRAY = getEnumNames(TARGET_TYPE);
const STATMOD_OP_ARRAY = getEnumNames(STATMOD_OP);
const AFFIX_PART_ID_ARRAY = getEnumNames(AFFIX_PART_ID);
const COMBAT_ACTION_TYPE_ARRAY = getEnumNames(COMBAT_ACTION_TYPE);

export {
  PSTAT,
  ELE_STAT,
  SKILL_TYPE,
  TARGET_TYPE,
  AFFIX_PART_ID,
  STATMOD_OP,
  COMBAT_ACTION_TYPE,
  PSTAT_ARRAY,
  ELE_STAT_ARRAY,
  SKILL_TYPE_ARRAY,
  TARGET_TYPE_ARRAY,
  STATMOD_OP_ARRAY,
  AFFIX_PART_ID_ARRAY,
  COMBAT_ACTION_TYPE_ARRAY,
};
