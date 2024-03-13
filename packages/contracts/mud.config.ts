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

const keysWithValue = (tableNames: string[]) =>
  tableNames.map((tableName) => ({
    name: "KeysWithValueModule",
    root: true,
    args: [resolveTableId(tableName)],
  }));

const durationTable = {
  keySchema: {
    targetEntity: EntityId,
    applicationEntity: EntityId,
  },
  valueSchema: {
    timeId: "bytes32",
    timeValue: "uint256",
  },
} as const;

const nameToEntityTable = {
  keySchema: {
    name: "bytes32",
  },
  valueSchema: EntityId,
} as const;

const keysInTable = (tableNames: string[]) =>
  tableNames.map((tableName) => ({
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId(tableName)],
  }));

const duration = (tableNames: string[]) =>
  tableNames.map((tableName) => ({
    name: "DurationModule",
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
    AffixAvailable: {
      keySchema: {
        affixPart: "AffixPartId",
        targetEntity: EntityId,
        ilvl: "uint32",
      },
      valueSchema: "bytes32[]",
    },
    AffixNaming: {
      keySchema: {
        affixPart: "AffixPartId",
        targetEntity: EntityId,
        protoEntity: EntityId,
      },
      valueSchema: "string",
    },
    AffixPrototype: {
      ...entityKey,
      valueSchema: {
        statmodProtoEntity: EntityId,
        tier: "uint32",
        requiredLevel: "uint32",
        min: "uint32",
        max: "uint32",
      },
    },
    AffixProtoIndex: {
      keySchema: {
        nameHash: "bytes32",
        tier: "uint32",
      },
      valueSchema: EntityId,
    },
    AffixProtoGroup: {
      keySchema: {
        nameHash: "bytes32",
      },
      valueSchema: EntityId,
    },
    Affix: {
      ...entityKey,
      valueSchema: {
        partId: "AffixPartId",
        protoEntity: EntityId,
        value: "uint32",
      },
    },
    ActiveGuise: entityRelation,
    GuisePrototype: {
      ...entityKey,
      valueSchema: arrayPStat,
    },
    GuiseSkills: {
      ...entityKey,
      valueSchema: EntityIdArray,
    },
    GuiseNameToEntity: nameToEntityTable,
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
    LootAffixes: {
      ...entityKey,
      valueSchema: EntityIdArray,
    },
    LootILvl: {
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
    SkillTemplateCooldown: {
      ...entityKey,
      valueSchema: {
        timeId: "bytes32",
        timeValue: "uint256",
      },
    },
    SkillTemplateDuration: {
      ...entityKey,
      valueSchema: {
        timeId: "bytes32",
        timeValue: "uint256",
      },
    },
    SkillDescription: "string",
    SkillNameToEntity: nameToEntityTable,
    SkillCooldown: durationTable,
    ActiveCycle: entityRelation,
    CycleToWanderer: entityRelation,
    CurrentCycle: entityRelation,
    PreviousCycle: entityRelation,
    CycleTurns: {
      ...entityKey,
      valueSchema: "uint32",
    },
    CycleTurnsLastClaimed: {
      ...entityKey,
      valueSchema: "uint48",
    },
    ActiveWheel: entityRelation,
    Identity: {
      ...entityKey,
      valueSchema: "uint32",
    },
    Wanderer: {
      ...entityKey,
      valueSchema: "bool",
    },
    WheelsCompleted: {
      keySchema: {
        wandererEntity: EntityId,
        wheelEntity: EntityId,
      },
      valueSchema: "uint32",
    },
    // initiatorEntity => retaliatorEntity
    // An entity can initiate only 1 combat at a time
    ActiveCombat: entityRelation,
    RNGPrecommit: {
      ...entityKey,
      valueSchema: "uint256",
    },
    // requestId => ownerEntity
    RNGRequestOwner: entityRelation,
    SlotAllowedTypes: {
      ...entityKey,
      valueSchema: {
        equipmentTypes: "bytes32[]",
      },
    },
    SlotEquipment: {
      ...entityKey,
      // equipment entity (not base)
      valueSchema: EntityId,
    },
    OwnedBy: entityRelation,

    /************************************************************************
     *
     *    DURATION MODULE
     *
     ************************************************************************/
    GenericDuration: {
      ...durationTable,
      tableIdArgument: true,
    },
    DurationIdxList: {
      keySchema: {
        sourceTableId: "ResourceId",
        targetEntity: EntityId,
        timeId: "bytes32",
      },
      valueSchema: {
        applicationEntities: EntityIdArray,
      },
      dataStruct: false,
    },
    DurationIdxMap: {
      keySchema: {
        sourceTableId: "ResourceId",
        targetEntity: EntityId,
        applicationEntity: EntityId,
      },
      valueSchema: {
        has: "bool",
        index: "uint40",
      },
      dataStruct: false,
    },

    /************************************************************************
     *
     *    STATMOD MODULE
     *
     ************************************************************************/
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

    /************************************************************************
     *
     *    EFFECT MODULE
     *
     ************************************************************************/
    EffectDuration: durationTable,
    EffectTemplate: {
      ...entityKey,
      valueSchema: {
        entities: EntityIdArray,
        values: "uint32[]",
      },
    },
    EffectApplied: {
      keySchema: {
        targetEntity: EntityId,
        applicationEntity: EntityId,
      },
      valueSchema: {
        entities: EntityIdArray,
        values: "uint32[]",
      },
    },
  },

  enums: {
    EleStat: enumEleStat,
    SkillType: ["COMBAT", "NONCOMBAT", "PASSIVE"],
    TargetType: ["SELF", "ENEMY", "ALLY", "SELF_OR_ALLY"],
    StatmodOp: ["ADD", "MUL", "BADD"],
    AffixPartId: ["IMPLICIT", "PREFIX", "SUFFIX"],
  },

  userTypes: {
    ResourceId: { filePath: "@latticexyz/store/src/ResourceId.sol", internalType: "bytes32" },
    StatmodTopic: {
      filePath: "./src/modules/statmod/StatmodTopic.sol",
      internalType: "bytes32",
    },
  },

  modules: [
    ...keysInTable(["Experience", "LearnedSkills", "EffectTemplate", "EffectApplied"]),
    ...keysWithValue(["AffixProtoGroup"]),
    {
      name: "UniqueEntityModule",
      root: true,
      args: [],
    },
    ...duration(["EffectDuration", "SkillCooldown"]),
    {
      name: "StatmodModule",
      root: true,
      args: [],
    },
    {
      name: "EffectModule",
      root: true,
      args: [],
    },
  ],
});
