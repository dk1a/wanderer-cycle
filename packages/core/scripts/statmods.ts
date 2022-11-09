export enum Op {
  ADD,
  MUL,
  BADD,
}

export enum Element {
  NONE,
  PHYSICAL,
  FIRE,
  COLD,
  POISON,
}

interface ModifierData {
  name: string
  topic: string
  op: Op
  element?: Element
}

// TODO rewrite this after you finalize the whole modifier and effect thing

// (solidity division rounds towards zero)
// usually result = (base + bAdd) * (100 + mul) / 100 + add
// where base is inherent attribute value (usually 0, 1 or Attributes-dependent)

// for consumable = (base + bAdd) * (0 + mul) / 100 + add
// where base depends on baseness

// consumable modifiers are modifiers consumed on use, skills can have them as well as items,
// they do not require the item/skill to be consumed on use

// helps avoid typos and search for keywords
const
  to = 'to',
  of = 'of',
  base = 'base',
  increased = 'increased',
  reduced = 'reduced',
  recover = 'recover',
  take = 'take',
  deal = 'deal',
  damage = 'damage',
  gained_each_turn = 'gained each turn',

  strength = 'strength',
  arcana = 'arcana',
  dexterity = 'dexterity',

  fortune = 'fortune',
  connection = 'connection',

  life = 'life',
  mana = 'mana',
  lifeRegen = 'lifeRegen',
  manaRegen = 'manaRegen',

  attack = 'attack',
  spell = 'spell',
  resistance = 'resistance',

  physical = 'physical',
  fire = 'fire',
  cold = 'cold',
  poison = 'poison',

  consumable = 'consumable'

const statmods: ModifierData[] = [
  // attributes: str = hp + attack dmg, dex = resistances + some attack dmg?, int = mana + spell dmg
  {
    name: `#% ${increased} ${strength}`,
    topic: strength,
    op: Op.MUL,
  },
  {
    name: `+# ${strength}`,
    topic: strength,
    op: Op.ADD,
  },
  {
    name: `#% ${increased} ${arcana}`,
    topic: arcana,
    op: Op.MUL,
  },
  {
    name: `+# ${arcana}`,
    topic: arcana,
    op: Op.ADD,
  },
  {
    name: `#% ${increased} ${dexterity}`,
    topic: dexterity,
    op: Op.MUL,
  },
  {
    name: `+# ${dexterity}`,
    topic: dexterity,
    op: Op.ADD,
  },
  // secondary attributes
  {
    name: `#% ${increased} ${fortune}`,
    topic: fortune,
    op: Op.MUL,
  },
  {
    name: `+# ${fortune}`,
    topic: fortune,
    op: Op.ADD,
  },
  {
    name: `#% ${increased} ${connection}`,
    topic: connection,
    op: Op.MUL,
  },
  {
    name: `+# ${connection}`,
    topic: connection,
    op: Op.ADD,
  },
  // resources
  {
    name: `#% ${increased} ${life}`,
    topic: life,
    op: Op.MUL,
  },
  {
    name: `+# ${life}`,
    topic: life,
    op: Op.ADD,
  },
  {
    name: `+# base ${life}`,
    topic: life,
    op: Op.BADD,
  },
  {
    name: `#% ${increased} ${mana}`,
    topic: mana,
    op: Op.MUL,
  },
  {
    name: `+# ${mana}`,
    topic: mana,
    op: Op.ADD,
  },
  {
    name: `+# base ${mana}`,
    topic: mana,
    op: Op.BADD,
  },
  // resources regen
  {
    name: `+# ${life} ${gained_each_turn}`,
    topic: lifeRegen,
    op: Op.ADD,
  },
  {
    name: `+# ${mana} ${gained_each_turn}`,
    topic: manaRegen,
    op: Op.ADD,
  },
  // attack
  {
    name: `+# ${physical} ${to} ${base} ${attack}`,
    topic: attack,
    op: Op.BADD,
    element: Element.PHYSICAL,
  },
  {
    name: `#% increased attack`,
    topic: attack,
    op: Op.MUL,
  },
  {
    name: `#% increased fire attack`,
    topic: attack,
    op: Op.MUL,
    element: Element.FIRE,
  },
  {
    name: `#% increased cold attack`,
    topic: attack,
    op: Op.MUL,
    element: Element.COLD,
  },
  {
    name: `+# ${physical} ${to} ${attack}`,
    topic: attack,
    op: Op.ADD,
    element: Element.PHYSICAL,
  },
  {
    name: `+# ${fire} ${to} ${attack}`,
    topic: attack,
    op: Op.ADD,
    element: Element.FIRE,
  },
  {
    name: `+# ${cold} ${to} ${attack}`,
    topic: attack,
    op: Op.ADD,
    element: Element.COLD,
  },
  {
    name: `+# ${poison} ${to} ${attack}`,
    topic: attack,
    op: Op.ADD,
    element: Element.POISON,
  },
  {
    name: `+#% of missing life to physical attack`,
    topic: 'portion of missing life attack',
    op: Op.ADD,
    element: Element.PHYSICAL
  },
  // spell
  {
    name: `#% ${increased} ${spell}`,
    topic: spell,
    op: Op.MUL,
  },
  {
    name: `+# ${to} ${physical} ${spell}`,
    topic: spell,
    op: Op.ADD,
    element: Element.PHYSICAL
  },
  {
    name: `+# ${to} ${fire} ${spell}`,
    topic: spell,
    op: Op.ADD,
    element: Element.FIRE
  },
  {
    name: `+# ${to} ${cold} ${spell}`,
    topic: spell,
    op: Op.ADD,
    element: Element.COLD
  },
  // resistances
  {
    name: `+# ${physical} ${resistance}`,
    topic: resistance,
    op: Op.ADD,
    element: Element.PHYSICAL,
  },
  {
    name: `+# ${fire} ${resistance}`,
    topic: resistance,
    op: Op.ADD,
    element: Element.FIRE,
  },
  {
    name: `+# ${cold} ${resistance}`,
    topic: resistance,
    op: Op.ADD,
    element: Element.COLD,
  },
  {
    name: `+# ${poison} ${resistance}`,
    topic: resistance,
    op: Op.ADD,
    element: Element.POISON,
  },
  // round damage
  {
    name: `take # ${physical} damage per round`,
    topic: 'round damage',
    op: Op.BADD,
    element: Element.PHYSICAL,
  },
  {
    name: `take # ${fire} damage per round`,
    topic: 'round damage',
    op: Op.BADD,
    element: Element.FIRE,
  },
  {
    name: `take # ${cold} damage per round`,
    topic: 'round damage',
    op: Op.BADD,
    element: Element.COLD,
  },
  {
    name: `take # ${poison} damage per round`,
    topic: 'round damage',
    op: Op.BADD,
    element: Element.POISON,
  },
  // debuffs
  {
    name: `${take} #% ${increased} ${damage}`,
    topic: 'damage taken add',
    op: Op.MUL,
  },
  {
    name: `${deal} # ${reduced} ${damage}`,
    topic: 'damage done sub',
    op: Op.ADD,
  },
  {
    name: `+# to rounds stunned`,
    topic: 'stun',
    op: Op.BADD,
  },
  // consumables
  // TODO you sure u wana use Baseness here?
  {
    name: `${recover} #% ${of} ${base} ${life}`,
    topic: consumable,
    op: Op.MUL,
    //baseness: Baseness.BASE,
  },
  {
    name: `${recover} # ${life}`,
    topic: consumable,
    op: Op.ADD,
    //baseness: Baseness.FINAL,
  },
  {
    name: `${recover} #% ${of} ${base} ${mana}`,
    topic: consumable,
    op: Op.MUL,
    //baseness: Baseness.BASE,
  },
  {
    name: `${recover} # ${mana}`,
    topic: consumable,
    op: Op.ADD,
    //baseness: Baseness.FINAL,
  },
  // map level
  {
    name: `+# map level`,
    topic: 'map level',
    op: Op.BADD,
  },
]

export default statmods