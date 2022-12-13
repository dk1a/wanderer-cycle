import { renderFile } from "ejs"
import { writeFileSync } from "fs"
import { extname, basename } from "path"

import { solExtractHashedStrings } from "./solExtractHashedStrings"

const libPath = "contracts/libraries/"

const deployData = {
  withLogs: false,
  withGenInits: true,
  components: [
    { name: "FromPrototypeComponent", path: "common" },
    { name: "NameComponent", path: "common" },
    { name: "ReverseHashNameComponent", path: "common" },

    { name: "TBTimeScopeComponent", path: "turn-based-time" },
    { name: "TBTimeValueComponent", path: "turn-based-time" },

    { name: "ExperienceComponent", path: "charstat" },
    { name: "LifeCurrentComponent", path: "charstat" },
    { name: "ManaCurrentComponent", path: "charstat" },

    { name: "StatmodPrototypeComponent", path: "statmod" },
    { name: "StatmodScopeComponent", path: "statmod" },
    { name: "StatmodValueComponent", path: "statmod" },

    { name: "EffectPrototypeComponent", path: "effect" },
    { name: "AppliedEffectComponent", path: "effect" },

    { name: "LearnedSkillsComponent", path: "skill" },
    { name: "SkillPrototypeComponent", path: "skill" },
    { name: "SkillPrototypeExtComponent", path: "skill" },

    { name: "EquipmentSlotComponent", path: "equipment" },
    { name: "EquipmentSlotAllowedComponent", path: "equipment" },
    { name: "EquipmentPrototypeComponent", path: "equipment" },

    { name: "ActiveGuiseComponent", path: "guise" },
    { name: "GuisePrototypeComponent", path: "guise" },
    { name: "GuisePrototypeExtComponent", path: "guise" },
    { name: "GuiseSkillsComponent", path: "guise" },

    { name: "ActiveCycleComponent", path: "cycle" },
  ],
  systems: [
    {
      path: "common",
      name: "ReverseHashNameSystem",
      writeAccess: ["ReverseHashNameComponent"],
    },
    {
      path: "statmod",
      name: "StatmodInitSystem",
      writeAccess: ["StatmodPrototypeComponent", "NameComponent"],
    },
    {
      path: "skill",
      name: "SkillPrototypeInitSystem",
      writeAccess: ["SkillPrototypeComponent", "SkillPrototypeExtComponent", "EffectPrototypeComponent"],
    },
    {
      path: "guise",
      name: "GuisePrototypeInitSystem",
      writeAccess: ["GuisePrototypeComponent", "GuisePrototypeExtComponent", "GuiseSkillsComponent"],
    },
    {
      path: "token",
      name: "WFTSystem",
      writeAccess: [],
    },
    {
      path: "token",
      name: "WNFTSystem",
      writeAccess: [],
    },
    {
      path: "cycle",
      name: "WandererSpawnSystem",
      writeAccess: ["ActiveCycleComponent", "ActiveGuiseComponent", "ExperienceComponent", "LifeCurrentComponent", "ManaCurrentComponent"],
      sysWriteAccess: ["WNFTSystem"],
    },
    {
      path: "combat",
      name: "CombatSystem",
      // TODO less total access
      writeAccess: ["*"],
    },
    {
      path: "equipment",
      name: "EquipmentSystem",
      // TODO less total access
      writeAccess: ["*"],
    },
  ],
  libPath: libPath,
  initLibs: [
    "LibInitReverseHashName",
    "LibInitStatmod",
    "LibInitSkill",
    "LibInitGuise",
    "LibInitEquipment"
  ]
}

function renderEjs(file: string, data: object) {
  renderFile(file, data, {}, (err, str) => {
    if (err) throw err
    const outFullPath = libPath + basename(file, extname(file)) + ".sol"
    writeFileSync(outFullPath, str)
    console.log(`generated: ${outFullPath}`)
  })
}

renderEjs(libPath + "LibDeploy.ejs", deployData)

renderEjs(libPath + "LibInitReverseHashName.ejs", {
  names: solExtractHashedStrings("contracts/charstat/Topics.sol")
})