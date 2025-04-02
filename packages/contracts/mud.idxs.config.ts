import { defineStoreIdxs } from "@dk1a/mud-table-idxs";
import storeConfig from "./mud.config";

export default defineStoreIdxs(
  {
    namespaces: {
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
          SkillName: [
            {
              fields: ["name"],
              unique: true,
            },
          ],
          SlotEquipment: [
            {
              fields: ["equipmentEntity"],
              unique: false,
            },
          ],
          ActiveCycle: [
            {
              fields: ["cycleEntity"],
              unique: true,
            },
          ],
        },
      },
    },
  },
  storeConfig,
);
