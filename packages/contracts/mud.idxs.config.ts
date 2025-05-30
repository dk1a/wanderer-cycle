import { defineStoreIdxs } from "@dk1a/mud-table-idxs";
import storeConfig from "./mud.config";

export default defineStoreIdxs(
  {
    namespaces: {
      common: {
        tables: {
          SOFClassName: [
            {
              fields: ["name"],
              unique: true,
            },
          ],
        },
      },
      duration: {
        tables: {
          GenericDuration: [
            {
              fields: ["targetEntity", "timeId"],
              unique: false,
            },
          ],
        },
      },
      statmod: {
        tables: {
          StatmodBase: [
            {
              fields: ["statmodTopic", "statmodOp", "eleStat"],
              unique: true,
            },
          ],
        },
      },
      skill: {
        tables: {
          SkillName: [
            {
              fields: ["name"],
              unique: true,
            },
          ],
        },
      },
      affix: {
        tables: {
          AffixPrototype: [
            {
              fields: ["exclusiveGroup"],
              unique: false,
            },
            {
              fields: ["affixTier", "name"],
              unique: true,
            },
          ],
        },
      },
      equipment: {
        tables: {
          SlotEquipment: [
            {
              fields: ["equipmentEntity"],
              unique: false,
            },
          ],
        },
      },
      wheel: {
        tables: {
          Wheel: [
            {
              fields: ["name"],
              unique: true,
            },
          ],
        },
      },
      root: {
        tables: {
          GuiseName: [
            {
              fields: ["name"],
              unique: true,
            },
          ],
        },
      },
    },
  },
  storeConfig,
);
