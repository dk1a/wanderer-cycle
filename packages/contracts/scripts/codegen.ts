import { renderFile } from "ejs"
import { writeFileSync, copyFileSync, readFileSync, mkdirSync } from "fs"
import { extname, basename, join, dirname, relative } from "path"
import glob from "glob"
import rimraf from "rimraf"

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

renderEjs("src/init/InitReverseHashNameSystem.ejs", {
  names: solExtractHashedStrings("src/charstat/Topics.sol")
})

// flatten everything within subdirs (however without recursing into their subdirs)
{
  const files = glob.sync("src/!(flattened)/!(LibDeploy).sol", {})
  const flattenedDir = "src/flattened"  
  rimraf.sync(flattenedDir)
  mkdirSync(flattenedDir)

  for (const file of files) {
    copyFileSync(file, join(flattenedDir, basename(file)))
  }
}

// generate test template
{
  const testFile = "src/BaseTest.ejs"

  const files = glob.sync("src/!(flattened)/*@(System|Subsystem|Component).sol", {})
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