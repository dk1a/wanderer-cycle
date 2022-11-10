import { renderFile } from "ejs"
import { readdirSync, readFileSync, writeFileSync } from "fs"
import { extname, basename } from "path"
import prepareStatmods from "./prepareStatmods"

const deployData = {
  withLogs: false,
  withGenInits: true,
  components: [
    { name: "TBTimeScopeComponent", path: "turn-based-time" },
    { name: "TBTimeValueComponent", path: "turn-based-time" },

    { name: "LifeCurrentComponent", path: "charstat" },
    { name: "ManaCurrentComponent", path: "charstat" },

    { name: "StatmodPrototypeComponent", path: "statmod" },
    { name: "StatmodPrototypeExtComponent", path: "statmod" },
    { name: "StatmodScopeComponent", path: "statmod" },
    { name: "StatmodValueComponent", path: "statmod" },

    { name: "AppliedEffectComponent", path: "effect" },

    { name: "LearnedSkillsComponent", path: "skill" },
    { name: "SkillPrototypeComponent", path: "skill" },
    { name: "SkillPrototypeExtComponent", path: "skill" },
  ],
  systems: [
    {
      path: "statmod",
      name: "StatmodInitSystem",
      writeAccess: ["StatmodPrototypeComponent", "StatmodPrototypeExtComponent"],
      generateInit: prepareStatmods()
    },
    {
      path: "skill",
      name: "SkillPrototypeInitSystem",
      writeAccess: ["SkillPrototypeComponent", "SkillPrototypeExtComponent"],
      manualInitLib: 'LibInitSkill'
    },
  ]
}

const libPath = "contracts/libraries/"

const ejsFiles = readdirSync(libPath).filter(file => {
  return extname(file).toLowerCase() === '.ejs'
})

for (const file of ejsFiles) {
  renderFile(libPath + file, deployData, (err, str) => {
    if (err) throw err
    const outFullPath = libPath + basename(file, extname(file)) + ".sol"
    writeFileSync(outFullPath, str)
    console.log(`generated: ${outFullPath}`)
  })
}

