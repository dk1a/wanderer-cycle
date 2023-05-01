import { mudConfig, resolveTableId } from "@latticexyz/config";

// TODO user-defined type
const EntityId = "uint256" as const
const EntityIdArray = "uint256[]" as const
// TODO set
const EntityIdSet = "uint256[]" as const

const entityKey = {
  primaryKeys: {
    entity: EntityId,
  },
} as const

const entityRelation = {
  ...entityKey,
  schema: EntityId,
} as const

const systemCallbackSchema = {
  namespace: "bytes16",
  file: "bytes16",
  funcSelectorAndArgs: "bytes"
} as const

const scopedDurationSchema = {
  scope: "bytes32",
  value: "uint48"
} as const

const enumPStat = ["STRENGTH", "ARCANA", "DEXTERITY"]
const arrayPStat = `uint32[${enumPStat.length}]` as const

const enumEleStat = ["NONE", "PHYSICAL", "FIRE", "COLD", "POISON"]
const arrayEleStat = `uint32[${enumEleStat.length}]` as const

const keysWithValue = (tableNames: string[]) => tableNames.map(tableName => ({
  name: "KeysWithValueModule",
  root: true,
  args: [resolveTableId(tableName)],
}))

export default mudConfig({
  tables: {
    KeyValueIndex: {
      directory: "../modules/keyvalueindex/tables",
      primaryKeys: {
        keyValueHash: "bytes32",
      },
      schema: {
        indexedKeys: "bytes32[]",
      },
      storeArgument: true,
      tableIdArgument: true,
    },

    Name: {
      ...entityKey,
      schema: "string",
    },
    FromPrototype: entityRelation,
    OwnedBy: entityRelation,
    FromMetaEntity: entityRelation,

    AffixAvailable: {
      primaryKeys: {
        affixPart: "AffixPartId",
        targetEntity: EntityId,
        ilvl: "uint32",
      },
      schema: "uint256[]",
    },
    AffixNaming: {
      primaryKeys: {
        affixPart: "AffixPartId",
        targetEntity: EntityId,
        protoEntity: EntityId,
      },
      schema: "string",
    },
    AffixPrototype: {
      ...entityKey,
      schema: {
        statmodProtoEntity: EntityId,
        tier: "uint32",
        requiredLevel: "uint32",
        min: "uint32",
        max: "uint32",
      },
    },
    AffixProtoIndex: {
      primaryKeys: {
        nameHash: "bytes32",
        tier: "uint32",
      },
      schema: EntityId,
    },
    AffixProtoGroup: {
      primaryKeys: {
        nameHash: "bytes32",
      },
      schema: EntityId,
    },
    Affix: {
      ...entityKey,
      schema: {
        partId: "AffixPartId",
        protoEntity: EntityId,
        value: "uint32"
      }
    },

    Experience: {
      ...entityKey,
      schema: arrayPStat
    },
    LifeCurrent: {
      ...entityKey,
      schema: "uint32",
    },
    ManaCurrent: {
      ...entityKey,
      schema: "uint32",
    },

    // initiatorEntity => retaliatorEntity
    // An entity can initiate only 1 combat at a time
    ActiveCombat: entityRelation,

    BossesDefeated: {
      ...entityKey,
      schema: "uint256[]",
    },
    CycleCombatRReq: {
      primaryKeys: {
        requestId: "bytes32"
      },
      schema: {
        mapEntity: EntityId,
        connection: "uint32",
        fortune: "uint32",
        winnerPStats: arrayPStat,
        loserPStats: arrayPStat
      }
    },
    CurrentCycle: entityRelation,
    PreviousCycle: entityRelation,
    CycleTurns: {
      ...entityKey,
      schema: "uint32",
    },
    CycleTurnsLastClaimed: {
      ...entityKey,
      schema: "uint48",
    },

    DurationScope: {
      primaryKeys: {
        targetEntity: EntityId,
        baseEntity: EntityId,
      },
      schema: "bytes32"
    },
    DurationValue: {
      primaryKeys: {
        targetEntity: EntityId,
        baseEntity: EntityId,
      },
      schema: "uint48"
    },
    DurationOnEnd: {
      ...entityKey,
      schema: systemCallbackSchema
    },

    EffectTemplate: {
      ...entityKey,
      schema: {
        entities: EntityIdArray,
        values: "uint32[]",
      }
    },
    EffectRemovability: {
      ...entityKey,
      schema: "EffectRemovabilityId",
    },
    EffectDuration: {
      ...entityKey,
      schema: scopedDurationSchema
    },
    EffectApplied: {
      primaryKeys: {
        targetEntity: EntityId,
        sourceEntity: EntityId,
      },
      schema: {
        entities: EntityIdArray,
        values: "uint32[]",
      }
    },

    EqptBase: {
      ...entityKey,
      schema: "bytes32"
    },
    FromEqptBase: entityRelation,
    SlotAllowedBases: {
      ...entityKey,
      // set of base equipment entities
      schema: EntityIdSet
    },
    SlotEquipment: {
      ...entityKey,
      // equipment entity (not base)
      schema: EntityId
    },

    ActiveGuise: entityRelation,
    ExpGainMul: {
      ...entityKey,
      schema: arrayPStat
    },
    AvailableSkills: {
      ...entityKey,
      schema: EntityIdSet
    },

    LootAffixes: {
      ...entityKey,
      // affix entities
      schema: EntityIdArray
    },
    LootIlvl: {
      ...entityKey,
      schema: "uint32"
    },

    MapBase: {
      ...entityKey,
      schema: "bytes32",
    },
    FromMapBase: entityRelation,

    RNGPrecommit: {
      ...entityKey,
      schema: "uint256",
    },
    // requestId => ownerEntity
    RNGRequestOwner: entityRelation,

    LearnedSkills: {
      ...entityKey,
      schema: EntityIdSet
    },
    SkillDescription: {
      ...entityKey,
      schema: "string"
    },
    SkillCooldown: {
      ...entityKey,
      schema: scopedDurationSchema
    },
    ManaCost: {
      ...entityKey,
      schema: arrayEleStat
    },
    SpellDamage: {
      ...entityKey,
      schema: arrayEleStat
    },
    // most skill entities also have EffectTemplate for the effect triggered by skill use
    SkillTemplate: {
      ...entityKey,
      schema: {
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
        targetType: "TargetType"
      }
    },

    StatmodBase: {
      ...entityKey,
      schema: "bytes32",
    },
    FromStatmodBase: entityRelation,
    StatmodBaseOpts: {
      ...entityKey,
      schema: {
        statmodOp: "StatmodOp",
        eleStat: "EleStat",
      }
    },
    StatmodScope: {
      primaryKeys: {
        targetEntity: EntityId,
        baseEntity: EntityId,
      },
      schema: "bytes32"
    },
    StatmodValue: {
      primaryKeys: {
        targetEntity: EntityId,
        baseEntity: EntityId,
      },
      schema: "uint32"
    },

    // TODO implement a proper ERC721
    WNFTOwnership: {
      primaryKeys: {
        tokenId: "uint256"
      },
      schema: "address"
    },

    Identity: {
      ...entityKey,
      schema: "uint32"
    },
    Wanderer: {
      ...entityKey,
      schema: "bool"
    },

    ActiveWheel: entityRelation,
    DefaultWheel: {
      primaryKeys: {},
      schema: EntityId
    },
    Wheel: {
      ...entityKey,
      schema: {
        totalIdentityRequired: "uint32",
        charges: "uint32",
        isIsolated: "bool"
      }
    },
    WheelsCompleted: {
      primaryKeys: {
        wandererEntity: EntityId,
        wheelEntity: EntityId
      },
      schema: "uint32"
    }
  },

  enums: {
    AffixPartId: ["IMPLICIT", "PREFIX", "SUFFIX"],
    EffectRemovabilityId: ["BUFF", "DEBUFF", "PERSISTENT"],
    PStat: enumPStat,
    EleStat: enumEleStat,
    SkillType: ["COMBAT", "NONCOMBAT", "PASSIVE"],
    TargetType: ["SELF", "ENEMY", "ALLY", "SELF_OR_ALLY"],
    StatmodOp: ["ADD", "MUL", "BADD"],
  },

  modules: [...keysWithValue(["DurationScope", "StatmodScope"])],
})