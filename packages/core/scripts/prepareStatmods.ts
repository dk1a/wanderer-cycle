import { id } from '@ethersproject/hash'
import { defaultAbiCoder } from '@ethersproject/abi'
import { idFromName } from "./utils"
import statmods, { Element } from "./statmods"

// for modifer names '#' is a placeholder for affix values.
// since string operations are expensive in solidity,
// pre-splitting allows it to just concatenate the parts around the value
function splitNameForValue(name: string) {
  const result = name.split('#', 2)
  if (result.length === 1) {
    result.push('')
  }
  return result
}

export default function prepareStatmods() {
  const entities = statmods.map(e => id(e.name))

  const prototypes = statmods.map(e => ({
    topic: idFromName(e.topic),
    op: e.op,
    element: e.element ?? Element.NONE,
  }))

  const prototypesExt = statmods.map(e => ({
    name: e.name,
    nameSplitForValue: splitNameForValue(e.name),
    topic: e.topic,
  }))

  const ethersHex = defaultAbiCoder.encode(
    [
      'uint256[]',
      'tuple(bytes4 topic, uint8 op, uint8 element)[]',
      'tuple(string name, string[2] nameSplitForValue, string topic)[]'
    ],
    [entities, prototypes, prototypesExt]
  )

  // remove 0x and add hex"..."
  // https://docs.ethers.io/v5/api/utils/abi/coder/
  // https://docs.soliditylang.org/en/latest/types.html#hexadecimal-literals
  const solidityLiteralHex = `hex"${ethersHex.slice(2)}"`
  return solidityLiteralHex
}