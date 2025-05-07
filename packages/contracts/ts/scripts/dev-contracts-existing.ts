import { execa } from "execa";
import worldsJson from "../../worlds.json";

const worldAddress = worldsJson[31337].address;
const rpc = "http://127.0.0.1:8545";

await execa("mud", ["dev-contracts", ["--worldAddress", worldAddress], ["--rpc", rpc]].flat(), {
  stdio: "inherit",
});
