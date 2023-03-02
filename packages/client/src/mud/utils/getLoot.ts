import { EntityIndex, getComponentValueStrict, World } from "@latticexyz/recs";
import { SetupResult } from "../setup";
import { getEffectPrototype } from "./getEffect";
import { AffixPartId, getLootAffixes, LootAffix } from "./getLootAffix";

export type LootData = ReturnType<typeof getLoot>;

type GetLootComponents = SetupResult["components"];

export function getLoot(world: World, components: GetLootComponents, entity: EntityIndex) {
  const { Name, Loot, FromPrototype, EffectPrototype, AffixNaming, AffixPrototype } = components;

  const loot = getComponentValueStrict(Loot, entity);
  const protoEntityId = getComponentValueStrict(FromPrototype, entity).value;
  const protoEntity = world.entityToIndex.get(protoEntityId);
  if (protoEntity === undefined) {
    throw new Error("No index for loot prototype entity");
  }
  const effect = getEffectPrototype(world, EffectPrototype, entity);
  if (effect === undefined) {
    throw new Error(`No effect for loot ${world.entities[entity]}`);
  }

  const affixes = getLootAffixes(
    world,
    { Name, AffixNaming, AffixPrototype },
    protoEntityId,
    loot.affixPartIds,
    loot.affixProtoEntities,
    loot.affixValues,
    effect.statmods
  );

  return {
    entity,
    name: getNameFromAffixes(affixes),
    ilvl: loot.ilvl,
    affixes,
    effect,
    protoEntityId,
    protoEntity,
  };
}

function getNameFromAffixes(affixes: LootAffix[]) {
  const implicits = affixes.filter(({ partId }) => partId === AffixPartId.IMPLICIT);
  const prefixes = affixes.filter(({ partId }) => partId === AffixPartId.PREFIX);
  const suffixes = affixes.filter(({ partId }) => partId === AffixPartId.SUFFIX);

  const ordered = prefixes.reverse().concat(implicits).concat(suffixes);
  return ordered.map(({ naming }) => naming).join(" ");
}
