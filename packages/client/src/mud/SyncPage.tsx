import { useClient } from "wagmi";
import { chainId } from "../common";
import { useStashCustom } from "./stash";
import { getSyncStatus } from "./getSyncStatus";
import { useWorldContract } from "./useWorldContract";
import { getBurnerClient } from "../getBurnerClient";

export function SyncPage() {
  const client = useClient({ chainId });
  const burnerClient = getBurnerClient();

  const status = useStashCustom((state) => getSyncStatus(state));
  const worldContract = useWorldContract();

  return (
    <div className="flex flex-col justify-center items-center h-screen">
      <div>
        <span className="text-dark-key">syncStatus</span>:{" "}
        <span className="text-dark-string">{status.message}</span> (
        {status.percentage.toFixed(1)}%)
      </div>

      <div className="mt-4">
        <span className="text-dark-key">connected</span>:{" "}
        <span className="text-dark-string">
          {worldContract?.address ?? "no"}
        </span>
      </div>

      <div className="mt-4">
        <span
          className="text-dark-control cursor-pointer"
          onClick={() => console.log({ client, burnerClient })}
        >
          logClients
        </span>
      </div>
    </div>
  );
}
