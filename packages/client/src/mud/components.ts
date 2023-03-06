import { defineComponent, Type } from "@latticexyz/recs";
import { defineBoolComponent, defineNumberComponent, defineStringComponent } from "@latticexyz/std-client";
import { defineEffectComponent } from "./components/EffectComponent";
import { defineEntityArrayComponent } from "./components/EntityArrayComponent";
import { defineEntityComponent } from "./components/EntityComponent";
import { world } from "./world";

export const components = {
  FromPrototype: defineEntityComponent(world, {
    metadata: {
      contractId: "component.FromPrototype",
    },
  }),
  Name: defineStringComponent(world, {
    metadata: {
      contractId: "component.Name",
    },
  }),
  ReverseHashName: defineStringComponent(world, {
    metadata: {
      contractId: "component.ReverseHashName",
    },
  }),
  RNGPrecommit: defineComponent(
    world,
    {
      blocknumber: Type.String,
      data: Type.String,
    },
    {
      id: "RNGPrecommit",
      metadata: { contractId: "component.RNGPrecommit" },
    }
  ),
  OwnedBy: defineEntityComponent(world, {
    metadata: {
      contractId: "component.OwnedBy",
    },
  }),

  DurationOnEnd: defineComponent(
    world,
    {
      systemId: Type.String,
      args: Type.String,
    },
    {
      id: "DurationOnEnd",
      metadata: { contractId: "component.DurationOnEnd" },
    }
  ),
  DurationScope: defineStringComponent(world, {
    metadata: {
      contractId: "component.DurationScope",
    },
  }),
  DurationValue: defineStringComponent(world, {
    metadata: {
      contractId: "component.DurationValue",
    },
  }),

  Experience: defineComponent(
    world,
    {
      strength: Type.Number,
      arcana: Type.Number,
      dexterity: Type.Number,
    },
    {
      id: "Experience",
      metadata: { contractId: "component.Experience" },
    }
  ),
  LifeCurrent: defineNumberComponent(world, {
    metadata: {
      contractId: "component.LifeCurrent",
    },
  }),
  ManaCurrent: defineNumberComponent(world, {
    metadata: {
      contractId: "component.ManaCurrent",
    },
  }),

  StatmodPrototype: defineComponent(
    world,
    {
      topicEntity: Type.Entity,
      op: Type.Number,
      element: Type.Number,
    },
    {
      id: "StatmodPrototype",
      metadata: { contractId: "component.StatmodPrototype" },
    }
  ),
  StatmodScope: defineStringComponent(world, {
    metadata: {
      contractId: "component.StatmodScope",
    },
  }),
  StatmodValue: defineStringComponent(world, {
    metadata: {
      contractId: "component.StatmodValue",
    },
  }),

  EffectPrototype: defineEffectComponent(world, {
    metadata: {
      contractId: "component.EffectPrototype",
    },
  }),
  AppliedEffect: defineEffectComponent(world, {
    metadata: {
      contractId: "component.AppliedEffect",
    },
  }),

  LearnedSkills: defineEntityArrayComponent(world, {
    metadata: {
      contractId: "component.LearnedSkills",
    },
  }),
  SkillPrototype: defineComponent(
    world,
    {
      requiredLevel: Type.Number,
      skillType: Type.Number,
      withAttack: Type.Boolean,
      withSpell: Type.Boolean,
      cost: Type.Number,
      duration_timeScopeId: Type.String,
      duration_timeValue: Type.String,
      cooldown_timeScopeId: Type.String,
      cooldown_timeValue: Type.String,
      effectTarget: Type.Number,
      spellDamage_all: Type.Number,
      spellDamage_physical: Type.Number,
      spellDamage_fire: Type.Number,
      spellDamage_cold: Type.Number,
      spellDamage_poison: Type.Number,
    },
    {
      id: "SkillPrototype",
      metadata: { contractId: "component.SkillPrototype" },
    }
  ),
  SkillDescription: defineStringComponent(world, {
    metadata: {
      contractId: "component.SkillDescription",
    },
  }),

  EquipmentSlot: defineEntityComponent(world, {
    metadata: {
      contractId: "component.EquipmentSlot",
    },
  }),
  EquipmentSlotAllowed: defineEntityArrayComponent(world, {
    metadata: {
      contractId: "component.EquipmentSlotAllowed",
    },
  }),
  EquipmentPrototype: defineBoolComponent(world, {
    metadata: {
      contractId: "component.EquipmentPrototype",
    },
  }),

  MapPrototype: defineBoolComponent(world, {
    metadata: {
      contractId: "component.MapPrototype",
    },
  }),

  AffixPrototype: defineComponent(
    world,
    {
      tier: Type.Number,
      statmodProtoEntity: Type.Entity,
      requiredIlvl: Type.Number,
      min: Type.Number,
      max: Type.Number,
    },
    {
      id: "AffixPrototype",
      metadata: { contractId: "component.AffixPrototype" },
    }
  ),
  AffixPrototypeGroup: defineEntityComponent(world, {
    metadata: {
      contractId: "component.AffixPrototypeGroup",
    },
  }),
  AffixNaming: defineStringComponent(world, {
    metadata: {
      contractId: "component.AffixNaming",
    },
  }),
  AffixAvailability: defineEntityArrayComponent(world, {
    metadata: {
      contractId: "component.AffixAvailability",
    },
  }),
  Loot: defineComponent(
    world,
    {
      ilvl: Type.Number,
      affixPartIds: Type.NumberArray,
      affixProtoEntities: Type.EntityArray,
      affixValues: Type.NumberArray,
    },
    {
      id: "Loot",
      metadata: { contractId: "component.Loot" },
    }
  ),

  ActiveGuise: defineEntityComponent(world, {
    metadata: {
      contractId: "component.ActiveGuise",
    },
  }),
  GuisePrototype: defineComponent(
    world,
    {
      levelMul_strength: Type.Number,
      levelMul_arcana: Type.Number,
      levelMul_dexterity: Type.Number,
    },
    {
      id: "GuisePrototype",
      metadata: { contractId: "component.GuisePrototype" },
    }
  ),
  GuiseSkills: defineEntityArrayComponent(world, {
    metadata: {
      contractId: "component.GuiseSkills",
    },
  }),

  Wanderer: defineBoolComponent(world, {
    metadata: {
      contractId: "component.Wanderer",
    },
  }),

  ActiveCycle: defineEntityComponent(world, {
    metadata: {
      contractId: "component.ActiveCycle",
    },
  }),
  ActiveCyclePrevious: defineEntityComponent(world, {
    metadata: {
      contractId: "component.ActiveCyclePrevious",
    },
  }),
  CycleTurns: defineNumberComponent(world, {
    metadata: {
      contractId: "component.CycleTurns",
    },
  }),
  CycleTurnsLastClaimed: defineStringComponent(world, {
    metadata: {
      contractId: "component.CycleTurnsLastClaimed",
    },
  }),
  CycleCombatRewardRequest: defineEntityComponent(world, {
    metadata: {
      contractId: "component.CycleCombatRewardRequest",
    },
  }),
  CycleBossesDefeated: defineEntityArrayComponent(world, {
    metadata: {
      contractId: "component.CycleBossesDefeated",
    },
  }),

  ActiveCombat: defineEntityComponent(world, {
    metadata: {
      contractId: "component.ActiveCombat",
    },
  }),

  // WNFTSystem components
  WNFT_OperatorApproval: defineBoolComponent(world, {
    metadata: {
      contractId: "component.WNFT_OperatorApproval",
    },
  }),
  WNFT_Ownership: defineEntityComponent(world, {
    metadata: {
      contractId: "component.WNFT_Ownership",
    },
  }),
  WNFT_TokenApproval: defineStringComponent(world, {
    metadata: {
      contractId: "component.WNFT_TokenApproval",
    },
  }),

  // WFTSystem components
  WFT_OperatorApproval: defineBoolComponent(world, {
    metadata: {
      contractId: "component.WFT_OperatorApproval",
    },
  }),
  WFT_Balance: defineNumberComponent(world, {
    metadata: {
      contractId: "component.WFT_Balance",
    },
  }),
};

export const clientComponents = {};
