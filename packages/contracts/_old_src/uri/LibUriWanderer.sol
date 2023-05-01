// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ActiveCycleComponent, ID as ActiveCycleComponentID } from "../cycle/ActiveCycleComponent.sol";
import { ActiveGuiseComponent, ID as ActiveGuiseComponentID } from "../guise/ActiveGuiseComponent.sol";
import { NameComponent, ID as NameComponentID } from "../common/NameComponent.sol";
import { LibGuiseLevel } from "../guise/LibGuiseLevel.sol";

import { UriUtils as u } from './UriUtils.sol';

library LibUriWanderer {
  // struct to avoid stack too deep error
  struct Strs {
    string[] cycles;
    string totalIdentityGained;
    string wandererNum;
    string guise;
    string level;
    string svgGuiseLevel;

    string output;
  }

  function json(IUint256Component components, uint256 tokenId) internal view returns (string memory) {
    Strs memory _strs;
    // TODO add real cycle stats
    //uint256 completedCycles = 0;
    //string memory strCyclesAll = Strings.toString(completedCycles);
    uint256 totalIdentityGained = 0;

    // TODO add real cycle stats
    uint256[] memory wheelEntities;
    _strs.cycles = new string[](wheelEntities.length);

    for (uint256 i; i < wheelEntities.length; i++) {
      // TODO add real cycle stats
      uint256 wheelIdentityGained = 0;

      totalIdentityGained += wheelIdentityGained;
      _strs.cycles[i] = Strings.toString(
        // TODO wheelCompletedCycles
        0
      );
    }
    _strs.totalIdentityGained = Strings.toString(totalIdentityGained);

    _strs.wandererNum = Strings.toHexString(
      uint32(bytes4(keccak256(abi.encode("Wanderer", tokenId))))
    );

    ActiveCycleComponent activeCycle = ActiveCycleComponent(getAddressById(components, ActiveCycleComponentID));
    if (activeCycle.has(tokenId)) {
      uint256 cycleEntity = activeCycle.getValue(tokenId);

      ActiveGuiseComponent activeGuise = ActiveGuiseComponent(getAddressById(components, ActiveGuiseComponentID));

      uint256 guiseEntity = activeGuise.getValue(cycleEntity);

      _strs.guise = NameComponent(getAddressById(components, NameComponentID)).getValue(guiseEntity);
      _strs.level = Strings.toString(LibGuiseLevel.getAggregateLevel(components, cycleEntity));
      _strs.svgGuiseLevel = string.concat(
        _strs.guise, ' ',
        '<tspan', u.ATTRS_NUM, '>',
          _strs.level,
        '</tspan>'
      );
    } else {
      _strs.guise = 'none';
      _strs.level = '0';
    }

    _strs.output = string.concat(
      u.START,
      '<text x="10" y="40"', u.ATTRS_TYPE, '>',
        'Wanderer ',
        '<tspan', u.ATTRS_BASE, '>',
          _strs.wandererNum,
        '</tspan>',
      '</text>',
      '<text x="10" y="80"', u.ATTRS_STRING, '>',
        _strs.svgGuiseLevel,
      '</text>',
      '<text x="10" y="120"', u.ATTRS_KEY, '>',
        'Total Identity ',
        '<tspan', u.ATTRS_NUM, '>',
          _strs.totalIdentityGained,
        '</tspan>',
      '</text>',
      u.END
    );

    return Base64.encode(abi.encodePacked(
      '{"name": "Wanderer ', _strs.wandererNum, '",'
      '"description": "Wanderer of their namesake Cycle",'
      '"attributes": ['
        '{'
          '"trait_type": "Base",'
          '"value": "Wanderer"'
        '},'
        '{'
          '"trait_type": "Guise",'
          '"value": "', _strs.guise, '"'
        '},'
        '{'
          '"trait_type": "Level",'
          '"value": ', _strs.level,
        '},'
        '{'
          '"trait_type": "Total Identity",'
          '"value": ', _strs.totalIdentityGained,
        '}'
      '],'
      //'"external_url": "",',
      //'"background_color": "000000",',
      '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(_strs.output)), '"}'
      //'"image_data": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'
    ));
  }
}