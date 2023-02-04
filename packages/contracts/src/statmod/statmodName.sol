// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { StrSlice, toSlice } from "@dk1a/solidity-stringutils/src/StrSlice.sol";

import { ReverseHashNameComponent } from "../common/ReverseHashNameComponent.sol";
import { Op, Element } from "./StatmodPrototypeComponent.sol";

using { toSlice } for string;

// utils for autogenerating a name for a statmod prototype

function statmodName(
  ReverseHashNameComponent rhNameComp,
  uint256 topicEntity,
  Op op
) view returns (string memory) {
  return statmodName(rhNameComp, topicEntity, op, Element.ALL);
}

function statmodName(
  ReverseHashNameComponent rhNameComp,
  uint256 topicEntity,
  Op op,
  Element element
) view returns (string memory) {
  StrSlice topicName = toSlice(rhNameComp.getValue(topicEntity));

  StrSlice[] memory nameParts = new StrSlice[](2);
  // prefix
  if (op == Op.ADD) {
    nameParts[0] = toSlice("+#");
  } else if (op == Op.MUL) {
    nameParts[0] = toSlice("#% increased");
  } else if (op == Op.BADD) {
    nameParts[0] = toSlice("+# base");
  } else {
    revert("unknown op");
  }
  // element + topic
  if (element != Element.ALL) {
    StrSlice elementName = _elementName(element);
    // check if topicName has "{element}" placeholder
    (bool found, StrSlice prefix, StrSlice suffix) = topicName.splitOnce(toSlice("{element}"));

    if (found) {
      // replace {element} with the actual element name
      nameParts[1] = prefix
        .add(elementName).toSlice()
        .add(suffix).toSlice();
    } else {
      // prepend element name to topicName
      nameParts[1] = elementName
        .add(toSlice(" ")).toSlice()
        .add(topicName).toSlice();
    }
  } else if (element == Element.ALL) {
    if (topicName.contains(toSlice("{element}"))) revert("invalid element placeholder");
    // just topicName, no element
    nameParts[1] = topicName;
  }

  return toSlice(" ").join(nameParts);
}

function _elementName(Element element) pure returns (StrSlice) {
  if (element == Element.PHYSICAL) {
    return toSlice("physical");
  } else if (element == Element.FIRE) {
    return toSlice("fire");
  } else if (element == Element.COLD) {
    return toSlice("cold");
  } else if (element == Element.POISON) {
    return toSlice("poison");
  } else {
    revert("unknown element");
  }
}