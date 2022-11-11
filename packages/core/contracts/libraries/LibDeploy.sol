// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { console } from "forge-std/console.sol";

// Solecs
import { World } from "solecs/World.sol";
import { Component } from "solecs/Component.sol";
import { getAddressById } from "solecs/utils.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { ISystem } from "solecs/interfaces/ISystem.sol";

// Components
import { TBTimeScopeComponent, ID as TBTimeScopeComponentID } from "../turn-based-time/TBTimeScopeComponent.sol";
import { TBTimeValueComponent, ID as TBTimeValueComponentID } from "../turn-based-time/TBTimeValueComponent.sol";
import { ExperienceComponent, ID as ExperienceComponentID } from "../charstat/ExperienceComponent.sol";
import { LifeCurrentComponent, ID as LifeCurrentComponentID } from "../charstat/LifeCurrentComponent.sol";
import { ManaCurrentComponent, ID as ManaCurrentComponentID } from "../charstat/ManaCurrentComponent.sol";
import { StatmodPrototypeComponent, ID as StatmodPrototypeComponentID } from "../statmod/StatmodPrototypeComponent.sol";
import { StatmodPrototypeExtComponent, ID as StatmodPrototypeExtComponentID } from "../statmod/StatmodPrototypeExtComponent.sol";
import { StatmodScopeComponent, ID as StatmodScopeComponentID } from "../statmod/StatmodScopeComponent.sol";
import { StatmodValueComponent, ID as StatmodValueComponentID } from "../statmod/StatmodValueComponent.sol";
import { AppliedEffectComponent, ID as AppliedEffectComponentID } from "../effect/AppliedEffectComponent.sol";
import { LearnedSkillsComponent, ID as LearnedSkillsComponentID } from "../skill/LearnedSkillsComponent.sol";
import { SkillPrototypeComponent, ID as SkillPrototypeComponentID } from "../skill/SkillPrototypeComponent.sol";
import { SkillPrototypeExtComponent, ID as SkillPrototypeExtComponentID } from "../skill/SkillPrototypeExtComponent.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "../guise/GuisePrototypeComponent.sol";
import { GuisePrototypeExtComponent, ID as GuisePrototypeExtComponentID } from "../guise/GuisePrototypeExtComponent.sol";
import { GuiseSkillsComponent, ID as GuiseSkillsComponentID } from "../guise/GuiseSkillsComponent.sol";

// Systems
import { StatmodInitSystem, ID as StatmodInitSystemID } from "../statmod/StatmodInitSystem.sol";
import { SkillPrototypeInitSystem, ID as SkillPrototypeInitSystemID } from "../skill/SkillPrototypeInitSystem.sol";
import { GuisePrototypeInitSystem, ID as GuisePrototypeInitSystemID } from "../guise/GuisePrototypeInitSystem.sol";

// Libraries
import { LibInit } from "./LibInit.sol";
import { LibInitSkill } from "./LibInitSkill.sol";
import { LibInitGuise } from "./LibInitGuise.sol";

struct DeployResult {
  World world;
  address deployer;
}

library LibDeploy {

  function deploy(
    address _deployer,
    address _world,
    bool _reuseComponents
  ) internal returns (DeployResult memory result) {
    result.deployer = _deployer;

    // ------------------------
    // Deploy 
    // ------------------------

    // Deploy world
    result.world = _world == address(0) ? new World() : World(_world);
    if(_world == address(0)) result.world.init(); // Init if it's a fresh world

      // Deploy components
    if(!_reuseComponents) {
      address comp;
      comp = address(new TBTimeScopeComponent(address(result.world)));
      comp = address(new TBTimeValueComponent(address(result.world)));
      comp = address(new ExperienceComponent(address(result.world)));
      comp = address(new LifeCurrentComponent(address(result.world)));
      comp = address(new ManaCurrentComponent(address(result.world)));
      comp = address(new StatmodPrototypeComponent(address(result.world)));
      comp = address(new StatmodPrototypeExtComponent(address(result.world)));
      comp = address(new StatmodScopeComponent(address(result.world)));
      comp = address(new StatmodValueComponent(address(result.world)));
      comp = address(new AppliedEffectComponent(address(result.world)));
      comp = address(new LearnedSkillsComponent(address(result.world)));
      comp = address(new SkillPrototypeComponent(address(result.world)));
      comp = address(new SkillPrototypeExtComponent(address(result.world)));
      comp = address(new GuisePrototypeComponent(address(result.world)));
      comp = address(new GuisePrototypeExtComponent(address(result.world)));
      comp = address(new GuiseSkillsComponent(address(result.world)));
    } 
    
    deploySystems(address(result.world), true);
  }
    
  
  function authorizeWriter(IUint256Component components, uint256 componentId, address writer) internal {
    Component(getAddressById(components, componentId)).authorizeWriter(writer);
  }
  
  function deploySystems(address _world, bool init) internal {
    World world = World(_world);
    // Deploy systems
    ISystem system; 
    IUint256Component components = world.components();
    system = new StatmodInitSystem(world, address(components));
    world.registerSystem(address(system), StatmodInitSystemID);
    authorizeWriter(components, StatmodPrototypeComponentID, address(system));
    authorizeWriter(components, StatmodPrototypeExtComponentID, address(system));
    if(init) LibInit.initStatmodInitSystem(system);
    system = new SkillPrototypeInitSystem(world, address(components));
    world.registerSystem(address(system), SkillPrototypeInitSystemID);
    authorizeWriter(components, SkillPrototypeComponentID, address(system));
    authorizeWriter(components, SkillPrototypeExtComponentID, address(system));
    if(init) LibInitSkill.initialize(world);
    system = new GuisePrototypeInitSystem(world, address(components));
    world.registerSystem(address(system), GuisePrototypeInitSystemID);
    authorizeWriter(components, GuisePrototypeComponentID, address(system));
    authorizeWriter(components, GuisePrototypeExtComponentID, address(system));
    authorizeWriter(components, GuiseSkillsComponentID, address(system));
    if(init) LibInitGuise.initialize(world);
  }
}