import { readFileSync } from "fs"
import { parse, visit } from "@solidity-parser/parser"

export function solExtractHashedStrings(file: string) {
  const data = readFileSync(file, 'utf8')
  const ast = parse(data, {tokens: true})

  const strs: Set<string> = new Set()

  visit(ast, {
    FunctionCall({expression, arguments: args}) {
      if (
        expression.type === 'Identifier'
        && expression.name === 'keccak256'
      ) {
        if (args[0].type === 'StringLiteral') {
          strs.add(args[0].value)
        }
      }
    }
  })

  return [...strs]
}