import { defineWorld } from "@latticexyz/world";
import { resolveTableId } from "@latticexyz/world/internal";
import { basicIdxModule, uniqueIdxModule } from "@dk1a/mud-table-idxs";
import {
  ELE_STAT_ARRAY,
  SKILL_TYPE_ARRAY,
  TARGET_TYPE_ARRAY,
  STATMOD_OP_ARRAY,
  AFFIX_PART_ID_ARRAY,
  PSTAT_ARRAY,
  COMBAT_ACTION_TYPE_ARRAY,
  COMBAT_RESULT_ARRAY,
} from "./enums";

const EntityId = "bytes32" as const;
const EntityIdArray = "bytes32[]" as const;
const EleStatStaticArray = "uint32[5]" as const;

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

const arrayPStat = `uint32[${PSTAT_ARRAY.length}]` as const;

const durationTable = {
  key: ["targetEntity", "applicationEntity"],
  schema: {
    targetEntity: EntityId,
    applicationEntity: EntityId,
    timeId: "bytes32",
    timeValue: "uint256",
  },
} as const;

const durationTemplateTable = {
  key: ["entity"],
  schema: {
    entity: EntityId,
    timeId: "bytes32",
    timeValue: "uint256",
  },
} as const;

const nameTable = {
  key: ["entity"],
  schema: {
    entity: EntityId,
    name: "string",
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
  AffixPartId: AFFIX_PART_ID_ARRAY,
  CombatActionType: COMBAT_ACTION_TYPE_ARRAY,
  CombatResult: COMBAT_RESULT_ARRAY,
};

const userTypes = {
  ResourceId: { filePath: "@latticexyz/store/src/ResourceId.sol", type: "bytes32" },
  AffixAvailabilityTargetId: { filePath: "./src/namespaces/affix/types.sol", type: "bytes32" },
  StatmodTopic: { filePath: "./src/namespaces/statmod/StatmodTopic.sol", type: "bytes32" },
  EquipmentType: { filePath: "./src/namespaces/equipment/EquipmentType.sol", type: "bytes32" },
  MapType: { filePath: "./src/namespaces/map/MapType.sol", type: "bytes32" },
} as const;

export default defineWorld({
  enums,
  userTypes,
  deploy: {
    customWorld: {
      sourcePath: "src/WorldWithContext.sol",
      name: "WorldWithContext",
    },
  },
  codegen: {
    generateSystemLibraries: true,
  },
  namespaces: {
    root: {
      namespace: "",
      tables: {
        GuisePrototype: {
          ...entityKey,
          schema: {
            entity: EntityId,
            arrayPStat: arrayPStat,
          },
        },
        GuiseName: nameTable,
        GuiseSkills: {
          ...entityKey,
          schema: {
            entity: EntityId,
            entityArray: EntityIdArray,
          },
        },
      },
    },
    /************************************************************************
     *
     *    SOF
     *    TODO: update the namespace etc when upstream changes
     *
     ************************************************************************/
    evefrontier: {
      systems: {
        EntitySystem: {
          deploy: {
            disabled: true,
            registerWorldFunctions: false,
          },
        },
      },
    },
    /************************************************************************
     *
     *    COMMON
     *
     ************************************************************************/
    common: {
      tables: {
        Name: nameTable,
        OwnedBy: entityRelation,
        // Names for SOF classes
        // Not all classes must have names, this is only used for easier access to the common ones
        SOFClassName: nameTable,
      },
    },
    /************************************************************************
     *
     *    DURATION
     *
     ************************************************************************/
    duration: {
      tables: {
        GenericDuration: {
          ...durationTable,
          codegen: {
            tableIdArgument: true,
          },
        },
      },
    },
    /************************************************************************
     *
     *    STATMOD
     *
     ************************************************************************/
    statmod: {
      tables: {
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
      },
    },
    /************************************************************************
     *
     *    CHARSTAT
     *
     ************************************************************************/
    charstat: {
      tables: {
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
        Experience: {
          ...entityKey,
          schema: {
            entity: EntityId,
            arrayPStat: arrayPStat,
          },
        },
      },
    },
    /************************************************************************
     *
     *    EFFECT
     *
     ************************************************************************/
    effect: {
      tables: {
        EffectDuration: durationTable,
        EffectTemplate: {
          ...entityKey,
          schema: {
            entity: EntityId,
            statmodEntities: EntityIdArray,
            values: "uint32[]",
          },
        },
        EffectApplied: {
          key: ["targetEntity", "applicationEntity"],
          schema: {
            targetEntity: EntityId,
            applicationEntity: EntityId,
            statmodEntities: EntityIdArray,
            values: "uint32[]",
          },
        },
      },
      systems: {
        EffectInternalSystem: {
          openAccess: false,
          accessList: [],
        },
      },
    },
    /************************************************************************
     *
     *    SKILL
     *
     ************************************************************************/
    skill: {
      tables: {
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
            value: EleStatStaticArray,
          },
        },
        SkillTemplateCooldown: durationTemplateTable,
        SkillTemplateDuration: durationTemplateTable,
        SkillName: nameTable,
        SkillDescription: {
          ...entityKey,
          schema: {
            entity: EntityId,
            value: "string",
          },
        },
        SkillCooldown: durationTable,
        LearnedSkills: {
          ...entityKey,
          schema: {
            entity: EntityId,
            skillEntities: EntityIdArray,
          },
        },
      },
    },
    /************************************************************************
     *
     *    TIME
     *
     ************************************************************************/
    time: {},
    /************************************************************************
     *
     *    COMBAT
     *
     ************************************************************************/
    combat: {
      tables: {
        CombatStatus: {
          ...entityKey,
          schema: {
            entity: EntityId,
            isInitialized: "bool",
            combatResult: "CombatResult",
            roundsSpent: "uint32",
            roundsMax: "uint32",
          },
        },
        CombatActors: {
          ...entityKey,
          schema: {
            entity: EntityId,
            initiatorEntity: EntityId,
            retaliatorEntity: EntityId,
          },
          codegen: {
            dataStruct: false,
          },
        },
        CombatLogRoundOffchain: {
          type: "offchainTable",
          key: ["entity", "roundIndex"],
          schema: {
            entity: EntityId,
            roundIndex: "uint256",
            combatResult: "CombatResult",
            initiatorActionLength: "uint256",
            retaliatorActionLength: "uint256",
          },
        },
        CombatLogActionOffchain: {
          type: "offchainTable",
          key: ["entity", "attackerEntity", "defenderEntity", "roundIndex", "actionIndex"],
          schema: {
            entity: EntityId,
            attackerEntity: EntityId,
            defenderEntity: EntityId,
            roundIndex: "uint256",
            actionIndex: "uint256",
            actionType: "CombatActionType",
            actionEntity: EntityId,
            defenderLifeBefore: "uint32",
            defenderLifeAfter: "uint32",
            withAttack: "bool",
            withSpell: "bool",
            attackDamage: EleStatStaticArray,
            spellDamage: EleStatStaticArray,
          },
        },
      },
    },
    /************************************************************************
     *
     *    AFFIX
     *
     ************************************************************************/
    affix: {
      tables: {
        AffixPrototype: {
          ...entityKey,
          schema: {
            entity: EntityId,
            statmodEntity: EntityId,
            exclusiveGroup: "bytes32",
            affixTier: "uint32",
            requiredLevel: "uint32",
            min: "uint32",
            max: "uint32",
            name: "string",
          },
        },
        Affix: {
          ...entityKey,
          schema: {
            entity: EntityId,
            affixPrototypeEntity: EntityId,
            partId: "AffixPartId",
            value: "uint32",
          },
        },
        AffixPrototypeAvailable: {
          key: ["affixPart", "targetId", "ilvl"],
          schema: {
            affixPart: "AffixPartId",
            targetId: "AffixAvailabilityTargetId",
            ilvl: "uint32",
            affixes: "bytes32[]",
          },
        },
        AffixNaming: {
          key: ["affixPart", "targetId", "affixPrototypeEntity"],
          schema: {
            affixPart: "AffixPartId",
            targetId: "AffixAvailabilityTargetId",
            affixPrototypeEntity: EntityId,
            label: "string",
          },
        },
      },
    },
    /************************************************************************
     *
     *    EQUIPMENT
     *
     ************************************************************************/
    equipment: {
      tables: {
        SlotAllowedType: {
          key: ["slotEntity", "equipmentType"],
          schema: {
            slotEntity: EntityId,
            equipmentType: "EquipmentType",
            isAllowed: "bool",
          },
        },
        SlotEquipment: {
          key: ["slotEntity"],
          schema: {
            slotEntity: EntityId,
            equipmentEntity: EntityId,
          },
        },
        EquipmentTypeComponent: {
          ...entityKey,
          schema: {
            entity: EntityId,
            value: "EquipmentType",
          },
        },
      },
    },
    /************************************************************************
     *
     *    MAP
     *
     ************************************************************************/
    map: {
      tables: {
        MapTypeComponent: {
          ...entityKey,
          schema: {
            entity: EntityId,
            value: "MapType",
          },
        },
      },
    },
    /************************************************************************
     *
     *    RNG
     *
     ************************************************************************/
    rng: {
      tables: {
        RNGPrecommit: {
          key: ["requestId"],
          schema: {
            requestId: "bytes32",
            value: "uint256",
          },
        },
        RNGRequestOwner: {
          key: ["requestId"],
          schema: {
            requestId: "bytes32",
            ownerEntity: EntityId,
          },
        },
      },
    },
    /************************************************************************
     *
     *    LOOT
     *
     ************************************************************************/
    loot: {
      tables: {
        LootAffixes: {
          ...entityKey,
          schema: {
            entity: EntityId,
            affixEntities: EntityIdArray,
          },
        },
        LootTargetId: {
          ...entityKey,
          schema: {
            entity: EntityId,
            targetId: "AffixAvailabilityTargetId",
          },
        },
        LootIlvl: {
          ...entityKey,
          schema: {
            entity: EntityId,
            value: "uint32",
          },
        },
      },
      systems: {
        RandomEquipmentSystem: {
          openAccess: false,
          accessList: ["CycleCombatRewardSystem"],
        },
        RandomMapSystem: {
          openAccess: false,
          accessList: [],
        },
      },
    },
    /************************************************************************
     *
     *    WHEEL
     *
     ************************************************************************/
    wheel: {
      tables: {
        Wheel: {
          ...entityKey,
          schema: {
            entity: EntityId,
            totalIdentityRequired: "uint32",
            charges: "uint32",
            isIsolated: "bool",
            name: "string",
          },
        },
        ActiveWheel: {
          key: ["cycleEntity"],
          schema: {
            cycleEntity: EntityId,
            wheelEntity: EntityId,
          },
        },
        CompletedWheelCount: {
          key: ["wandererEntity", "wheelEntity"],
          schema: {
            wandererEntity: EntityId,
            wheelEntity: EntityId,
            value: "uint256",
          },
        },
        IdentityCurrent: {
          key: ["wandererEntity"],
          schema: {
            wandererEntity: EntityId,
            value: "uint256",
          },
        },
        IdentityEarnedTotal: {
          key: ["wandererEntity"],
          schema: {
            wandererEntity: EntityId,
            value: "uint256",
          },
        },
      },
      systems: {
        WheelSystem: {
          openAccess: false,
          accessList: ["InitCycleSystem", "CycleControlSystem", "PermSkillSystem"],
        },
      },
    },
    /************************************************************************
     *
     *    CYCLE
     *
     ************************************************************************/
    cycle: {
      tables: {
        ActiveCycle: {
          ...entityKey,
          schema: {
            entity: EntityId,
            cycleEntity: EntityId,
          },
        },
        ActiveGuise: {
          ...entityKey,
          schema: {
            entity: EntityId,
            guiseEntity: EntityId,
          },
        },
        // A cycle entity can initiate only 1 combat at a time
        ActiveCombat: {
          ...entityKey,
          schema: {
            entity: EntityId,
            combatEntity: EntityId,
          },
        },
        CycleOwner: {
          ...entityKey,
          schema: {
            entity: EntityId,
            ownerEntity: EntityId,
          },
        },
        CycleMetadata: {
          ...entityKey,
          schema: {
            entity: EntityId,
            // timestamp
            startTime: "uint256",
            // timestamp
            endTime: "uint256",
          },
        },
        CompletedCycleHistory: {
          key: ["wandererEntity"],
          schema: {
            wandererEntity: EntityId,
            cycleEntities: EntityIdArray,
          },
        },
        RequiredBossMaps: {
          key: [],
          schema: {
            mapEntities: EntityIdArray,
          },
        },
        BossesDefeated: {
          ...entityKey,
          schema: {
            entity: EntityId,
            value: "bytes32[]",
          },
        },
        CycleCombatRReq: {
          key: ["requestId"],
          schema: {
            requestId: "bytes32",
            mapEntity: EntityId,
            connection: "uint32",
            fortune: "uint32",
            winnerPStat: arrayPStat,
            loserPStat: arrayPStat,
          },
        },
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
            // timestamp
            value: "uint256",
          },
        },
        // TODO not sure where to put this table, maybe rethink the logic using it entirely
        FromMap: {
          key: ["encounterEntity"],
          schema: {
            encounterEntity: EntityId,
            mapEntity: EntityId,
          },
        },
      },
      systems: {
        InitCycleSystem: {
          openAccess: false,
          accessList: ["WandererSpawnSystem"],
        },
      },
    },
    /************************************************************************
     *
     *    WANDERER
     *
     ************************************************************************/
    wanderer: {
      tables: {
        Wanderer: {
          ...entityKey,
          schema: {
            entity: EntityId,
            value: "bool",
          },
        },
      },
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
      artifactPath: "erc721-local/out/ERC721Module.sol/ERC721Module.json",
      root: false,
      args: [],
    },
    {
      artifactPath: "@latticexyz/world-modules/out/UniqueEntityModule.sol/UniqueEntityModule.json",
      root: true,
      args: [],
    },
    basicIdxModule,
    uniqueIdxModule,
    ...keysInTable(["Experience", "LearnedSkills", "EffectTemplate", "EffectApplied"]),
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
