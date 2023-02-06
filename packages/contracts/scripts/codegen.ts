import { renderFile } from "ejs"
import { writeFileSync, readFileSync } from "fs"
import { extname, basename, join, dirname, relative } from "path"
import glob from "glob"

import { solExtractHashedStrings } from "./solExtractHashedStrings"

function renderEjs(file: string, data: object) {
  renderFile(file, data, {}, (err, str) => {
    if (err) throw err
    const solFile = basename(file, extname(file)) + ".sol"
    const outFullPath = join(dirname(file), solFile)
    writeFileSync(outFullPath, str)
    console.log(`generated: ${outFullPath}`)
  })
}

renderEjs("src/init/LibInitReverseHashName.ejs", {
  names: solExtractHashedStrings("src/charstat/Topics.sol")
})

// generate test template
{
  const testFile = "src/BaseTest.ejs"

  const files = glob.sync("src/!(flattened)/*@(System|Component).sol", {})
  // only keeps what's in deploy config
  const config = JSON.parse(readFileSync("deploy.json", { encoding: "utf8" }))
  const namedFiles = files
    .map(file => ({
      file: "./" + relative(dirname(testFile), file),
      name: basename(file, ".sol")
    }))
    .filter(({name}) =>
      config.components?.includes(name)
      || config.systems?.map(({name: _name}: {name: string}) => _name).includes(name)
    )

  const components = namedFiles.filter(({name}) => name.endsWith('Component'))
  const systems = namedFiles.filter(({name}) => !name.endsWith('Component'))
  renderEjs(testFile, { components, systems })
}