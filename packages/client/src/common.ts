export const chainId = import.meta.env.CHAIN_ID;
export const worldAddress = import.meta.env.WORLD_ADDRESS;
export const startBlock = BigInt(import.meta.env.START_BLOCK ?? 0n);

export const url = new URL(window.location.href);

export function getWorldAddress() {
  if (!worldAddress) {
    throw new Error(
      "No world address configured. Is the world still deploying?",
    );
  }
  return worldAddress;
}
