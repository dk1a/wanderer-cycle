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
    },
  },
  storeConfig,
);
