import { task, types } from "hardhat/config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { strToBytes16, checkNameStr } from '../scripts/utils'

export interface AddModifiersTaskArgs {
  owner: string
  file: string
  address?: string
  silent?: string
}

function checkKey(obj: any, key: string) {
  const str: string|undefined = obj[key]
  const valid = str === undefined || checkNameStr(str)
  if (!valid) {
    throw Error(`Invalid key ${key}: ${str}`)
  }
}

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

task("addModifiers", "Creates modifiers")
  .addParam("owner", "Address of contract owner")
  .addParam("file", "File with data")
  .addOptionalParam("address", "Address of manager contract")
  .addOptionalParam("silent", "Whether to log details")

  .setAction(
    async (
      taskArgs: AddModifiersTaskArgs,
      hre: HardhatRuntimeEnvironment
    ) => {
      // get data from file
      const file: string = taskArgs.file
      const modifiers: ModifierData[] = require(`../data/modifiers/${file}.ts`).default
      if (!taskArgs.silent) {
        console.log("modifiers:\n==========\n" + modifiers.map(e => e.name).join("\n") + "\n==========\n")
      }

      // check data (not exhaustive)
      modifiers.forEach(e => {
        checkKey(e, 'name')
        checkKey(e, 'topic')
        if (e.topic === 'consumable' && e.baseness === undefined) {
          throw Error('"consumable" topic needs baseness: ' + e.name)
        }
      })
      // add computed values, impute data and transform topics to bytes
      const modifierStructs = modifiers.map(e => ({
        name: e.name,
        nameSplitForValue: splitNameForValue(e.name),
        topic: e.topic,
        op: e.op,
        element: e.element ?? Element.NONE,
        baseness: e.baseness ?? Baseness.FINAL,
      }))

      await addStuff(taskArgs, hre, 'Modifier', 'addModifiers', [modifierStructs])
    }
  )