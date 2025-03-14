import { defineStoreIdxs } from "@dk1a/mud-table-idxs";
import storeConfig from "./mud.config";

export default defineStoreIdxs(
  {
    namespaces: {
      duration: {
        tables: {
          GenericDuration: {
            Idx_GenericDuration_TargetEntityTimeId: {
              fields: ["targetEntity", "timeId"],
              unique: false,
            },
          },
        },
      },
      affix: {
        tables: {
          AffixPrototype: {
            Idx_AffixPrototype_ExclusiveGroup: {
              fields: ["exclusiveGroup"],
              unique: false,
            },
            UniqueIdx_AffixPrototype_TierName: {
              fields: ["affixTier", "name"],
              unique: true,
            },
          },
        },
      },
      root: {
        tables: {
          SlotEquipment: {
            Idx_SlotEquipment_Equipment: {
              fields: ["equipmentEntity"],
              unique: false,
            },
          },
        },
      },
    },
  },
  storeConfig,
);
