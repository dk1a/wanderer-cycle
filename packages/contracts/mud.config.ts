import { mudConfig, resolveTableId } from "@latticexyz/world/register";

// TODO user-defined type
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
  schema: EntityId,
} as const;

const systemCallbackSchema = {
  namespace: "bytes16",
  file: "bytes16",
  funcSelectorAndArgs: "bytes",
} as const;

const scopedDurationSchema = {
  scope: "bytes32",
  value: "uint48",
} as const;

const enumPStat = ["STRENGTH", "ARCANA", "DEXTERITY"];
const arrayPStat = `uint32[${enumPStat.length}]` as const;

const enumEleStat = ["NONE", "PHYSICAL", "FIRE", "COLD", "POISON"];
const arrayEleStat = `uint32[${enumEleStat.length}]` as const;

const keysWithValue = (tableNames: string[]) =>
  tableNames.map((tableName) => ({
    name: "KeysWithValueModule",
    root: true,
    args: [resolveTableId(tableName)],
  }));

export default mudConfig({
  tables: {
    Counter: {
      keySchema: {},
      schema: "uint32",
    },
    Experience: {
      ...entityKey,
      schema: arrayPStat,
    },
    ActiveGuise: entityRelation,
    GuisePrototype: {
      ...entityKey,
      schema: arrayPStat,
    },
    ActiveCycle: {
      ...entityKey,
      schema: "uint32",
    },
    CycleTurns: {
      ...entityKey,
      schema: "uint32",
    },
    CycleTurnsLastClaimed: {
      ...entityKey,
      schema: "uint48",
    },
    RNGPrecommit: {
      ...entityKey,
      schema: "uint256",
    },
    // requestId => ownerEntity
    RNGRequestOwner: entityRelation,
  },
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Experience")],
    },
    {
      name: "UniqueEntityModule",
      root: true,
      args: [],
    },
  ],
});
