// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { StrSlice, toSlice } from "@dk1a/solidity-stringutils/src/StrSlice.sol";

import { StatmodBaseData } from "../codegen/index.sol";
import { StatmodOp, EleStat } from "../codegen/common.sol";

using { toSlice } for string;

// utils for autogenerating a name for a statmod

function statmodName(StatmodBaseData memory statmodBase) view returns (string memory) {
  StrSlice topicName = toSlice(statmodBase.statmodTopic.toString());

  StrSlice[] memory nameParts = new StrSlice[](2);
  // prefix
  if (statmodBase.statmodOp == StatmodOp.ADD) {
    nameParts[0] = toSlice("+#");
  } else if (statmodBase.statmodOp == StatmodOp.MUL) {
    nameParts[0] = toSlice("#% increased");
  } else if (statmodBase.statmodOp == StatmodOp.BADD) {
    nameParts[0] = toSlice("+# base");
  } else {
    revert("unknown op");
  }
  // eleStat + statmodTopic
  if (statmodBase.eleStat != EleStat.NONE) {
    StrSlice elementName = _elementName(statmodBase.eleStat);
    // check if topicName has "{el}" placeholder
    (bool found, StrSlice prefix, StrSlice suffix) = topicName.splitOnce(toSlice("{el}"));

    if (found) {
      // replace {el} with the actual element name
      nameParts[1] = prefix.add(elementName).toSlice().add(suffix).toSlice();
    } else {
      // prepend element name to topicName
      nameParts[1] = elementName.add(toSlice(" ")).toSlice().add(topicName).toSlice();
    }
  } else if (statmodBase.eleStat == EleStat.NONE) {
    if (topicName.contains(toSlice("{el}"))) revert("invalid eleStat placeholder");
    // just topicName, no eleStat
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
