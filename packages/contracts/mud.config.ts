import { defineWorld } from "@latticexyz/world";
import { resolveTableId } from "@latticexyz/world/internal";
import {
  ELE_STAT_ARRAY,
  SKILL_TYPE_ARRAY,
  TARGET_TYPE_ARRAY,
  STATMOD_OP_ARRAY,
  ACTION_TYPE_ARRAY,
  AFFIX_PART_ID_ARRAY,
  PSTAT_ARRAY,
  COMBAT_ACTION_TYPE_ARRAY,
} from "./enums";

const EntityId = "bytes32" as const;
const EntityIdArray = "bytes32[]" as const;
// TODO set
const EntityIdSet = "bytes32[]" as const;

const entityKey = {
  key: ["entity"],
} as const;

const entityRelation = {
  key: ["fromEntity"],
  schema: {
    fromEntity: EntityId,
    toEntity: EntityId,
  },
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

const arrayPStat = `uint32[${PSTAT_ARRAY.length}]` as const;

const keysWithValue = (tableNames: string[]) =>
  tableNames.map((tableName) => ({
    artifactPath: "@latticexyz/world-modules/out/KeysWithValueModule.sol/KeysWithValueModule.json",
    root: true,
    args: [resolveTableId(tableName)],
  }));

const durationTable = {
  key: ["targetEntity", "applicationEntity"],
  schema: {
    targetEntity: EntityId,
    applicationEntity: EntityId,
    timeId: "bytes32",
    timeValue: "uint256",
  },
} as const;

const nameToEntityTable = {
  key: ["name"],
  schema: {
    name: "bytes32",
    entity: EntityId,
  },
} as const;

const keysInTable = (tableNames: string[]) =>
  tableNames.map((tableName) => ({
    artifactPath: "@latticexyz/world-modules/out/KeysInTableModule.sol/KeysInTableModule.json",
    root: true,
    args: [resolveTableId(tableName)],
  }));

const duration = (tableNames: string[]) =>
  tableNames.map((tableName) => ({
    artifactPath: "./out/DurationModule.sol/DurationModule.json",
    root: true,
    args: [resolveTableId(tableName)],
  }));

const enums = {
  EleStat: ELE_STAT_ARRAY,
  SkillType: SKILL_TYPE_ARRAY,
  TargetType: TARGET_TYPE_ARRAY,
  StatmodOp: STATMOD_OP_ARRAY,
  ActionType: ACTION_TYPE_ARRAY,
  AffixPartId: AFFIX_PART_ID_ARRAY,
  CombatActionType: COMBAT_ACTION_TYPE_ARRAY,
};

const userTypes = {
  ResourceId: { filePath: "@latticexyz/store/src/ResourceId.sol", type: "bytes32" },
  StatmodTopic: { filePath: "./src/modules/statmod/StatmodTopic.sol", type: "bytes32" },
  MapType: { filePath: "./src/map/MapType.sol", type: "bytes32" },
} as const;

export default defineWorld({
  enums,
  userTypes,
  tables: {
    Tasks: {
      schema: {
        id: "bytes32",
        createdAt: "uint256",
        completedAt: "uint256",
        description: "string",
      },
      key: ["id"],
    },
    ERC721Config: {
      key: ["namespace"],
      schema: {
        namespace: "bytes14",
        tokenAddress: "address",
      },
    },
    Name: "string",
    DefaultWheel: {
      key: [],
      schema: {
        entity: EntityId,
      },
    },
    Wheel: {
      ...entityKey,
      schema: {
        entity: EntityId,
        totalIdentityRequired: "uint32",
        charges: "uint32",
        isIsolated: "bool",
      },
    },
    Experience: {
      ...entityKey,
      schema: {
        entity: EntityId,
        arrayPStat: arrayPStat,
      },
    },
    AffixAvailable: {
      key: ["affixPart", "affixAvailabilityEntity", "ilvl"],
      schema: {
        affixPart: "AffixPartId",
        affixAvailabilityEntity: EntityId,
        ilvl: "uint32",
        affixes: "bytes32[]",
      },
    },
    AffixNaming: {
      key: ["affixPart", "affixAvailabilityEntity", "protoEntity"],
      schema: {
        affixPart: "AffixPartId",
        affixAvailabilityEntity: EntityId,
        protoEntity: EntityId,
        name: "string",
      },
    },
    AffixPrototype: {
      ...entityKey,
      schema: {
        entity: EntityId,
        statmodProtoEntity: EntityId,
        tier: "uint32",
        requiredLevel: "uint32",
        min: "uint32",
        max: "uint32",
      },
    },
    AffixProtoIndex: {
      key: ["nameHash", "tier"],
      schema: {
        nameHash: "bytes32",
        tier: "uint32",
        entity: EntityId,
      },
    },
    AffixProtoGroup: {
      key: ["nameHash"],
      schema: {
        nameHash: "bytes32",
        entity: EntityId,
      },
    },
    Affix: {
      ...entityKey,
      schema: {
        entity: EntityId,
        partId: "AffixPartId",
        protoEntity: EntityId,
        value: "uint32",
      },
    },
    ActiveGuise: entityRelation,
    GuisePrototype: {
      ...entityKey,
      schema: {
        entity: EntityId,
        affixPart: arrayPStat,
      },
    },
    GuiseSkills: {
      ...entityKey,
      schema: {
        entity: EntityId,
        entityArray: EntityIdArray,
      },
    },
    GuiseNameToEntity: nameToEntityTable,
    LearnedSkills: {
      ...entityKey,
      schema: {
        entity: EntityId,
        entityIdSet: EntityIdSet,
      },
    },
    LifeCurrent: {
      ...entityKey,
      schema: {
        entity: EntityId,
        value: "uint32",
      },
    },
    ManaCurrent: {
      ...entityKey,
      schema: {
        entity: EntityId,
        value: "uint32",
      },
    },
    LootAffixes: {
      ...entityKey,
      schema: {
        entity: EntityId,
        entityArray: EntityIdArray,
      },
    },
    LootIlvl: {
      ...entityKey,
      schema: {
        entity: EntityId,
        value: "uint32",
      },
    },
    SkillTemplate: {
      ...entityKey,
      schema: {
        entity: EntityId,
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
    SkillSpellDamage: {
      ...entityKey,
      schema: {
        entity: EntityId,
        value: "uint32[5]",
      },
    },
    SkillTemplateCooldown: {
      ...entityKey,
      schema: {
        entity: EntityId,
        timeId: "bytes32",
        timeValue: "uint256",
      },
    },
    SkillTemplateDuration: {
      ...entityKey,
      schema: {
        entity: EntityId,
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
      schema: {
        entity: EntityId,
        value: "uint32",
      },
    },
    CycleTurnsLastClaimed: {
      ...entityKey,
      schema: {
        entity: EntityId,
        value: "uint48",
      },
    },
    ActiveWheel: entityRelation,
    Identity: {
      ...entityKey,
      schema: {
        entity: EntityId,
        value: "uint32",
      },
    },
    Wanderer: {
      ...entityKey,
      schema: {
        entity: EntityId,
        spawn: "bool",
      },
    },
    WheelsCompleted: {
      key: ["wandererEntity", "wheelEntity"],
      schema: {
        wandererEntity: EntityId,
        wheelEntity: EntityId,
        value: "uint32",
      },
    },
    // An entity can initiate only 1 combat at a time
    ActiveCombat: {
      key: ["initiatorEntity"],
      schema: {
        initiatorEntity: EntityId,
        retaliatorEntity: EntityId,
        roundsSpent: "uint32",
        roundsMax: "uint32",
      },
    },
    RNGPrecommit: {
      ...entityKey,
      schema: {
        entity: EntityId,
        value: "uint256",
      },
    },
    // requestId => ownerEntity
    RNGRequestOwner: entityRelation,
    SlotAllowedTypes: {
      ...entityKey,
      schema: {
        entity: EntityId,
        equipmentTypes: "bytes32[]",
      },
    },
    SlotEquipment: entityRelation,
    OwnedBy: entityRelation,
    MapTypeComponent: {
      ...entityKey,
      schema: {
        entity: EntityId,
        value: "MapType",
      },
    },
    MapTypeAffixAvailability: {
      key: ["label"],
      schema: {
        label: "bytes32",
        entity: EntityId,
      },
    },

    /************************************************************************
     *
     *    DURATION MODULE
     *
     ************************************************************************/
    GenericDuration: {
      ...durationTable,
      codegen: {
        tableIdArgument: true,
      },
    },
    DurationIdxList: {
      key: ["sourceTableId", "targetEntity", "timeId"],
      schema: {
        sourceTableId: "ResourceId",
        targetEntity: EntityId,
        timeId: "bytes32",
        applicationEntities: EntityIdArray,
      },
      codegen: {
        dataStruct: false,
      },
    },
    DurationIdxMap: {
      key: ["sourceTableId", "targetEntity", "applicationEntity"],
      schema: {
        sourceTableId: "ResourceId",
        targetEntity: EntityId,
        applicationEntity: EntityId,
        has: "bool",
        index: "uint40",
      },
      codegen: {
        dataStruct: false,
      },
    },

    /************************************************************************
     *
     *    STATMOD MODULE
     *
     ************************************************************************/
    StatmodBase: {
      ...entityKey,
      schema: {
        entity: EntityId,
        statmodTopic: "StatmodTopic",
        statmodOp: "StatmodOp",
        eleStat: "EleStat",
      },
    },
    StatmodValue: {
      key: ["targetEntity", "baseEntity"],
      schema: {
        targetEntity: EntityId,
        baseEntity: EntityId,
        value: "uint32",
      },
    },
    StatmodIdxList: {
      key: ["targetEntity", "statmodTopic"],
      schema: {
        targetEntity: EntityId,
        statmodTopic: "StatmodTopic",
        baseEntities: EntityIdArray,
      },
      codegen: {
        dataStruct: false,
      },
    },
    StatmodIdxMap: {
      key: ["targetEntity", "baseEntity"],
      schema: {
        targetEntity: EntityId,
        baseEntity: EntityId,
        statmodTopic: "StatmodTopic",
        has: "bool",
        index: "uint40",
      },
      codegen: {
        dataStruct: false,
      },
    },

    /************************************************************************
     *
     *    EFFECT MODULE
     *
     ************************************************************************/
    EffectDuration: durationTable,
    EffectTemplate: {
      ...entityKey,
      schema: {
        entity: EntityId,
        entities: EntityIdArray,
        values: "uint32[]",
      },
    },
    EffectApplied: {
      key: ["targetEntity", "applicationEntity"],
      schema: {
        targetEntity: EntityId,
        applicationEntity: EntityId,
        entities: EntityIdArray,
        values: "uint32[]",
      },
    },
  },
  systems: {
    CombatSystem: {
      openAccess: false,
      accessList: [],
    },
    RandomMapSystem: {
      openAccess: false,
      accessList: [],
    },
  },
  modules: [
    {
      artifactPath: "@latticexyz/world-modules/out/StandardDelegationsModule.sol/StandardDelegationsModule.json",
      root: true,
      args: [],
    },
    {
      artifactPath: "@latticexyz/world-modules/out/PuppetModule.sol/PuppetModule.json",
      root: true,
      args: [],
    },
    {
      artifactPath: "@latticexyz/world-modules/out/UniqueEntityModule.sol/UniqueEntityModule.json",
      root: true,
      args: [],
    },
    ...keysInTable(["Experience", "LearnedSkills", "EffectTemplate", "EffectApplied"]),
    ...keysWithValue(["AffixProtoGroup"]),
    ...duration(["EffectDuration", "SkillCooldown"]),
    {
      artifactPath: "./out/StatmodModule.sol/StatmodModule.json",
      root: true,
      args: [],
    },
    {
      artifactPath: "./out/EffectModule.sol/EffectModule.json",
      root: true,
      args: [],
    },
  ],
});
