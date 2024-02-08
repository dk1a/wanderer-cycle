// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { StrSlice, toSlice } from "@dk1a/solidity-stringutils/src/StrSlice.sol";

import { ReverseHashName } from "../codegen/index.sol";
import { StatmodOp, EleStat } from "../codegen/common.sol";

using { toSlice } for string;

// utils for autogenerating a name for a statmod prototype

function statmodName(bytes32 topicEntity, StatmodOp statmodOp) view returns (string memory) {
  return statmodName(topicEntity, statmodOp, EleStat.NONE);
}

function statmodName(bytes32 topicEntity, StatmodOp statmodOp, EleStat eleStat) view returns (string memory) {
  StrSlice topicName = toSlice(ReverseHashName.get(topicEntity));

  StrSlice[] memory nameParts = new StrSlice[](2);
  // prefix
  if (statmodOp == StatmodOp.ADD) {
    nameParts[0] = toSlice("+#");
  } else if (statmodOp == StatmodOp.MUL) {
    nameParts[0] = toSlice("#% increased");
  } else if (statmodOp == StatmodOp.BADD) {
    nameParts[0] = toSlice("+# base");
  } else {
    revert("unknown op");
  }
  // element + topic
  if (eleStat != EleStat.NONE) {
    StrSlice elementName = _elementName(eleStat);
    // check if topicName has "{element}" placeholder
    (bool found, StrSlice prefix, StrSlice suffix) = topicName.splitOnce(toSlice("{eleStat}"));

    if (found) {
      // replace {element} with the actual element name
      nameParts[1] = prefix.add(elementName).toSlice().add(suffix).toSlice();
    } else {
      // prepend element name to topicName
      nameParts[1] = elementName.add(toSlice(" ")).toSlice().add(topicName).toSlice();
    }
  } else if (eleStat == EleStat.NONE) {
    if (topicName.contains(toSlice("{eleStat}"))) revert("invalid element placeholder");
    // just topicName, no element
    nameParts[1] = topicName;
  }

  return toSlice(" ").join(nameParts);
}

function _elementName(EleStat eleStat) pure returns (StrSlice) {
  if (eleStat == EleStat.PHYSICAL) {
    return toSlice("physical");
  } else if (eleStat == EleStat.FIRE) {
    return toSlice("fire");
  } else if (eleStat == EleStat.COLD) {
    return toSlice("cold");
  } else if (eleStat == EleStat.POISON) {
    return toSlice("poison");
  } else {
    revert("unknown element");
  }
}
