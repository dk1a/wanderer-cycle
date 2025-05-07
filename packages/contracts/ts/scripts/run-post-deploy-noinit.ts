import { execa } from "execa";
import worldsJson from "../../worlds.json";

const worldAddress = worldsJson[31337].address;
const rpc = "http://127.0.0.1:8545";

await execa(
  "forge",
  [
    "script",
    "script/PostDeploy.s.sol:PostDeploy",
    ["--sig", "runNoInit(address)", worldAddress],
    ["--rpc-url", rpc],
    "--broadcast",
    "-vvv",
  ].flat(),
  {
    stdio: "inherit",
  },
);
