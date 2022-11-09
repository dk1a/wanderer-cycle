import { toUtf8Bytes } from '@ethersproject/strings'
import { id } from '@ethersproject/hash'
import { hexDataSlice } from '@ethersproject/bytes'

export const facets = [
  'AstralDataFacet',
  'AstralSkillFacet',
  'AstralTurnsFacet',

  'CycleTransitionFacet',

  'CycleDataFacet',
  'CycleSkillFacet',
  'CycleTurnsFacet',

  'EncounterFacet',
  'EncounterDataFacet',
  'EncounterRewardFacet',

  'EquipmentFacet',

  'Guise',

  'AffixFacet',
  'LootFacet',

  'Modifier',

  'Multicall',

  'SkillFacet',

  'TokenWalletDataProvider',

  'VRFConsumerFacet',

  'WTokens',
  'WTokensMintWandererFacet',
  'WTokensUri'
]

// generic check for valid names of stuff
export function checkNameStr(str: string) {
  return str === str.trim() && str.length > 2
    && str === str.replaceAll('\0', '')
}

// appends 0s to end of string to make it match given bytesize
export function strToBytesN(str: string, nBytes: number) {
  if (nBytes < 1 || nBytes > 32) {
    throw Error('nBytes must be between 1 and 32')
  }
  const bytes = toUtf8Bytes(str)
  if (bytes.length > nBytes) {
    throw Error(`bytes string too long: ${str}`)
  }
  const result = new Uint8Array(nBytes);
  result.set(bytes)
  return result
}

export function strToBytes4(str: string) {
  return strToBytesN(str, 4)
}

export function strToBytes8(str: string) {
  return strToBytesN(str, 8)
}

export function strToBytes16(str: string) {
  return strToBytesN(str, 16)
}

export function strToBytes32(str: string) {
  return strToBytesN(str, 32)
}

export function idFromName(name: string) {
  return hexDataSlice(id(name), 0, 4);
}