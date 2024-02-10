import { mudConfig, resolveTableId } from "@latticexyz/world/register";

const EntityId = "bytes32" as const;
const EntityIdArray = "bytes32[]" as const;
// TODO set
const EntityIdSet = "bytes32[]" as const;

const entityKey = {
  keySchema: {
    entity: EntityId,
  },
} as const;

const entityRelation = {
  ...entityKey,
  valueSchema: EntityId,
} as const;

/*const systemCallbackSchema = {
  namespace: "bytes16",
  file: "bytes16",
  funcSelectorAndArgs: "bytes",
} as const;

const scopedDurationSchema = {
  scope: "bytes32",
  value: "uint48",
} as const;*/

const enumPStat = ["STRENGTH", "ARCANA", "DEXTERITY"];
const arrayPStat = `uint32[${enumPStat.length}]` as const;

const enumEleStat = ["NONE", "PHYSICAL", "FIRE", "COLD", "POISON"];
//const arrayEleStat = `uint32[${enumEleStat.length}]` as const;

/*const keysWithValue = (tableNames: string[]) =>
  tableNames.map((tableName) => ({
    name: "KeysWithValueModule",
    root: true,
    args: [resolveTableId(tableName)],
  }));*/

const keysInTable = (tableNames: string[]) =>
  tableNames.map((tableName) => ({
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId(tableName)],
  }));

export default mudConfig({
  tables: {
    Name: {
      ...entityKey,
      valueSchema: "string",
    },
    DefaultWheel: {
      keySchema: {},
      valueSchema: EntityId,
    },
    Wheel: {
      ...entityKey,
      valueSchema: {
        totalIdentityRequired: "uint32",
        charges: "uint32",
        isIsolated: "bool",
      },
    },
    Experience: {
      ...entityKey,
      valueSchema: arrayPStat,
    },
    ActiveGuise: entityRelation,
    GuisePrototype: {
      ...entityKey,
      valueSchema: arrayPStat,
    },
    LearnedSkills: {
      ...entityKey,
      valueSchema: EntityIdSet,
    },
    LifeCurrent: {
      ...entityKey,
      valueSchema: "uint32",
    },
    ManaCurrent: {
      ...entityKey,
      valueSchema: "uint32",
    },
    SkillTemplate: {
      ...entityKey,
      valueSchema: {
        // level required to learn it
        requiredLevel: "uint8",
        // when/how it can be used
        skillType: "SkillType",
        // flag to also trigger an attack afterwards (base attack damage is not based on the skill)
        withAttack: "bool",
        // flag to also trigger a spell afterwards (`SpellDamage` is used for base damage)
        withSpell: "bool",
        // mana cost to be subtracted on use
        cost: "uint32",
        // who it can be used on
        targetType: "TargetType",
      },
    },
    EffectTemplate: {
      ...entityKey,
      valueSchema: {
        entities: EntityIdArray,
        values: "uint32[]",
      },
    },
    StatmodBase: {
      ...entityKey,
      valueSchema: {
        statmodTopic: "StatmodTopic",
        statmodOp: "StatmodOp",
        eleStat: "EleStat",
      },
    },
    StatmodValue: {
      keySchema: {
        targetEntity: EntityId,
        baseEntity: EntityId,
      },
      valueSchema: "uint32",
    },
    StatmodIdxList: {
      keySchema: {
        targetEntity: EntityId,
        statmodTopic: "StatmodTopic",
      },
      valueSchema: {
        baseEntities: EntityIdArray,
      },
    },
    StatmodIdxMap: {
      keySchema: {
        targetEntity: EntityId,
        baseEntity: EntityId,
      },
      valueSchema: {
        statmodTopic: "StatmodTopic",
        has: "bool",
        index: "uint40",
      },
      dataStruct: false,
    },
    // initiatorEntity => retaliatorEntity
    // An entity can initiate only 1 combat at a time
    ActiveCombat: entityRelation,
    ActiveCycle: {
      ...entityKey,
      valueSchema: "uint32",
    },
    CycleTurns: {
      ...entityKey,
      valueSchema: "uint32",
    },
    CycleTurnsLastClaimed: {
      ...entityKey,
      valueSchema: "uint48",
    },
    RNGPrecommit: {
      ...entityKey,
      valueSchema: "uint256",
    },
    // requestId => ownerEntity
    RNGRequestOwner: entityRelation,
  },

  enums: {
    EleStat: enumEleStat,
    SkillType: ["COMBAT", "NONCOMBAT", "PASSIVE"],
    TargetType: ["SELF", "ENEMY", "ALLY", "SELF_OR_ALLY"],
    StatmodOp: ["ADD", "MUL", "BADD"],
  },

  userTypes: {
    StatmodTopic: {
      filePath: "./src/statmod/StatmodTopic.sol",
      internalType: "bytes32",
    },
  },

  modules: [
    ...keysInTable(["Experience", "LearnedSkills"]),
    {
      name: "UniqueEntityModule",
      root: true,
      args: [],
    },
  ],
});
