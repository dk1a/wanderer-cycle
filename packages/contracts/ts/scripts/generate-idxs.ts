import path from "node:path";
import { fileURLToPath } from "node:url";
import { idxgen } from "@dk1a/mud-table-idxs";

import storeConfig from "../../mud.config";
import idxsConfig from "../../mud.idxs.config";

const rootDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");

await idxgen({ rootDir, idxsConfig, storeConfig });
