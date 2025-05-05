import { ReactNode } from "react";
import { WagmiProvider } from "wagmi";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";
import { createSyncAdapter } from "@latticexyz/store-sync/internal";
import { SyncProvider } from "@latticexyz/store-sync/react";
import { stash } from "./mud/stash";
import { chainId, getWorldAddress, startBlock } from "./common";
import { wagmiConfig } from "./wagmiConfig";

const queryClient = new QueryClient();

export function GlobalProviders({ children }: { children: ReactNode }) {
  const worldAddress = getWorldAddress();
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <SyncProvider
          chainId={chainId}
          address={worldAddress}
          startBlock={startBlock}
          adapter={createSyncAdapter({ stash })}
        >
          {children}
        </SyncProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
