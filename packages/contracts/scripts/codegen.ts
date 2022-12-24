import { renderFile } from "ejs"
import { writeFileSync, copyFileSync, mkdirSync } from "fs"
import { extname, basename, join } from "path"
import glob from "glob"
import rimraf from "rimraf"

import { solExtractHashedStrings } from "./solExtractHashedStrings"

const initPath = "src/init/"

function renderEjs(file: string, data: object) {
  renderFile(file, data, {}, (err, str) => {
    if (err) throw err
    const outFullPath = initPath + basename(file, extname(file)) + ".sol"
    writeFileSync(outFullPath, str)
    console.log(`generated: ${outFullPath}`)
  })
}

renderEjs(initPath + "InitReverseHashNameSystem.ejs", {
  names: solExtractHashedStrings("src/charstat/Topics.sol")
})

// flatten components and systems
const files = glob.sync("src/!(flattened)/!(LibDeploy).sol", {})
const flattenedDir = "src/flattened"  
rimraf.sync(flattenedDir)
mkdirSync(flattenedDir)

for (const file of files) {
  copyFileSync(file, join(flattenedDir, basename(file)))
}