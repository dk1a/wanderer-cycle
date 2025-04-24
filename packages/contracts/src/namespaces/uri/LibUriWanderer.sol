// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { StrSlice, toSlice } from "@dk1a/solidity-stringutils/src/StrSlice.sol";

import { GuiseName } from "../root/codegen/tables/GuiseName.sol";
import { ActiveCycle } from "../cycle/codegen/tables/ActiveCycle.sol";
import { ActiveGuise } from "../cycle/codegen/tables/ActiveGuise.sol";
import { IdentityEarnedTotal } from "../wheel/codegen/tables/IdentityEarnedTotal.sol";
import { CompletedWheelCount } from "../wheel/codegen/tables/CompletedWheelCount.sol";
import { Wheel, WheelData } from "../wheel/codegen/tables/Wheel.sol";

import { LibWheel } from "../wheel/LibWheel.sol";
import { LibGuiseLevel } from "../root/guise/LibGuiseLevel.sol";

import { UriUtils as u } from "./UriUtils.sol";

library LibUriWanderer {
  // struct to avoid stack too deep error
  struct Strs {
    string completedWheelAttributes;
    string completedWheelSvg;
    string totalIdentityGained;
    string wandererNum;
    string guise;
    string level;
    string svgGuiseLevel;
  }

  uint256 constant X_PAD_NUM = 20;
  string constant X_PAD_STR = "20";

  string constant Y_WANDERER = "20";
  uint256 constant Y_WHEELS = 60;
  string constant Y_IDENTITY = "80";
  string constant Y_GUISE = "340";

  function json(bytes32 wandererEntity) internal view returns (string memory) {
    Strs memory _strs;

    string[2] memory wheels = ["Wheel of Attainment", "Wheel of Isolation"];

    for (uint256 i; i < wheels.length; i++) {
      (string memory completedWheelCountString, string memory completedWheelCountSvg) = wheelTexts(
        wandererEntity,
        wheels[i],
        X_PAD_NUM + i * 10,
        Y_WHEELS
      );

      // prettier-ignore
      _strs.completedWheelAttributes = string.concat(
        _strs.completedWheelAttributes,
        '{'
          '"trait_type": "', wheels[i],'",'
          '"value": ', completedWheelCountString,
        '},'
      );

      _strs.completedWheelSvg = string.concat(_strs.completedWheelSvg, completedWheelCountSvg);
    }
    _strs.totalIdentityGained = Strings.toString(IdentityEarnedTotal.get(wandererEntity));

    _strs.wandererNum = Strings.toHexString(uint64(bytes8(keccak256("Wanderer"))));

    bytes32 cycleEntity = ActiveCycle.get(wandererEntity);
    if (cycleEntity != bytes32(0)) {
      bytes32 guiseEntity = ActiveGuise.get(cycleEntity);

      _strs.guise = GuiseName.get(guiseEntity);
      _strs.level = Strings.toString(LibGuiseLevel.getAggregateLevel(cycleEntity));
      // prettier-ignore
      _strs.svgGuiseLevel = string.concat(
        _strs.guise, ' ',
        '<tspan', u.ATTRS_NUM, '>',
          _strs.level,
        '</tspan>'
      );
    } else {
      _strs.guise = "none";
      _strs.level = "0";
    }

    // string.concat() whith too many arguments seems to cause stack too deep error
    // prettier-ignore
    string memory output = string.concat(
      u.START,
      '<text y="', Y_WANDERER,'"', u.ATTRS_HEADER_TYPE, '>',
        'Wanderer ',
        '<tspan', u.ATTRS_BASE, '>',
          _strs.wandererNum,
        '</tspan>',
      '</text>'
    );
    // prettier-ignore
    output = string.concat(
      output,
      _strs.completedWheelSvg,
      '<text x="' , X_PAD_STR, '" y="', Y_IDENTITY, '"', u.ATTRS_KEY, '>',
        'identity ',
        '<tspan', u.ATTRS_NUM, '>',
          _strs.totalIdentityGained,
        '</tspan>',
      '</text>'
    );
    // prettier-ignore
    output = string.concat(
      output,
      '<text x="', X_PAD_STR,'" y="', Y_GUISE, '"', u.ATTRS_STRING, '>',
        _strs.svgGuiseLevel,
      '</text>',
      u.END
    );

    // prettier-ignore
    return Base64.encode(abi.encodePacked(
      '{"name": "Wanderer ', _strs.wandererNum, '",'
      '"description": "Wanderer of the Cycle",'
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
      '"background_color": "#1e1e1e",',
      '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'
    ));
  }

  function wheelTexts(
    bytes32 wandererEntity,
    string memory wheelName,
    uint256 x,
    uint256 y
  ) internal view returns (string memory completedWheelCountString, string memory completedWheelCountSvg) {
    bytes32 wheelEntity = LibWheel.getWheelEntity(wheelName);
    WheelData memory wheel = Wheel.get(wheelEntity);

    uint256 completedWheelCount = CompletedWheelCount.get(wandererEntity, wheelEntity);
    completedWheelCountString = Strings.toString(completedWheelCount);

    string memory svgInnerWheelName;
    string memory svgInnerText;
    if (completedWheelCount > 0) {
      (, , StrSlice suffix) = toSlice(wheelName).rsplitOnce(toSlice(" "));
      svgInnerWheelName = suffix.toString();

      if (completedWheelCount >= wheel.charges) {
        // prettier-ignore
        svgInnerText = string.concat(
          '<tspan', u.ATTRS_METHOD, '>',
            '+',
          '</tspan>'
        );
      } else {
        // prettier-ignore
        svgInnerText = string.concat(
          '<tspan', u.ATTRS_BASE, '>',
            Strings.toString(completedWheelCount),
          '</tspan>'
        );
      }
    }

    // prettier-ignore
    completedWheelCountSvg = string.concat(
      '<text x="', Strings.toString(x), '" y="', Strings.toString(y), '" textLength="10" lengthAdjust="spacingAndGlyphs" ', u.ATTRS_KEY, '>',
        svgInnerWheelName,
      '</text>',
      '<text x="', Strings.toString(x + X_PAD_NUM / 2), '" y="', Strings.toString(y), '">',
        svgInnerText,
      '</text>'
    );
  }
}
