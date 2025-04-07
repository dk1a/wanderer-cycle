import { Hex, hexToString, isHex, trim } from "viem";

export function formatEntity(entity: Hex): string {
  if (entity.length <= 10) {
    return entity;
  }
  const start = entity.slice(0, 5);
  const end = entity.slice(-5);
  return `${start}...${end}`;
}

// TODO ideally this should accept Hex
export function formatZeroTerminatedString(hex: string): string {
  if (!isHex(hex)) {
    console.error(`Attempted to format non-hex string: ${hex}`);
    return hex;
  }
  return hexToString(trim(hex, { dir: "right" }));
}
