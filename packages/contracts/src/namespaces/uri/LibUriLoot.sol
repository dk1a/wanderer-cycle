// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { StrSlice, toSlice } from "@dk1a/solidity-stringutils/src/StrSlice.sol";

import { Name } from "../common/codegen/tables/Name.sol";
import { LootAffixes } from "../loot/codegen/tables/LootAffixes.sol";
import { AffixPrototype, AffixPrototypeData } from "../affix/codegen/tables/AffixPrototype.sol";
import { Affix, AffixData } from "../affix/codegen/tables/Affix.sol";
import { AffixNaming } from "../affix/codegen/tables/AffixNaming.sol";
import { LootTargetId } from "../loot/codegen/tables/LootTargetId.sol";
import { LootIlvl } from "../loot/codegen/tables/LootIlvl.sol";
import { AffixPartId } from "../../codegen/common.sol";

import { UriUtils as u } from "./UriUtils.sol";

library LibUriLoot {
  function json(bytes32 lootEntity) internal view returns (string memory) {
    string memory lootName;
    string[3] memory lootNameLines;
    // generic attributes for opensea etc
    string memory affixesAttrs;
    // affix mods as svg text
    string memory affixesSvg;

    AffixData[] memory affixes = getOrderedAffixes(lootEntity);

    for (uint256 i; i < affixes.length; i++) {
      AffixData memory affix = affixes[i];
      AffixPrototypeData memory affixPrototype = AffixPrototype.get(affix.affixPrototypeEntity);

      // Part to which the affix applies (e.g. "prefix")
      // AffixPartId determines affix availability and loot naming
      string memory partName;
      if (affix.partId == AffixPartId.PREFIX) {
        partName = "prefix";
      } else if (affix.partId == AffixPartId.IMPLICIT) {
        partName = "implicit";
      } else if (affix.partId == AffixPartId.SUFFIX) {
        partName = "suffix";
      }

      // Loot naming parts (e.g. "of the Fox"), as determined by affixes
      string memory affixNaming = AffixNaming.get(
        affix.partId,
        LootTargetId.get(lootEntity),
        affix.affixPrototypeEntity
      );
      lootName = string.concat(lootName, bytes(lootName).length == 0 ? "" : " ", affixNaming);
      pickAndAppendLootNameLine(lootNameLines, affixNaming);

      // Split the affix's statmod name (e.g. "+# to life") on "#" to replace it with the value
      (, StrSlice statmodNameSplitLeft, StrSlice statmodNameSplitRight) = toSlice(
        Name.get(affixPrototype.statmodEntity)
      ).splitOnce(toSlice("#"));

      // Each applied affix can be sufficiently described by its name, tier, part and value
      // (whereas for affix prototypes name and tier are sufficient)
      string memory traitType = string.concat(
        affixPrototype.name,
        ":",
        Strings.toString(affixPrototype.affixTier),
        ":",
        partName
      );

      // prettier-ignore
      affixesAttrs = string.concat(affixesAttrs,
        '{'
          '"trait_type": "', traitType, '",'
          '"value": ', Strings.toString(affix.value),
        '},'
      );

      // prettier-ignore
      affixesSvg = string.concat(affixesSvg,
        '<text x="10" y="', Strings.toString(60 + i * 15),'"', u.ATTRS_STRING, '>',
          statmodNameSplitLeft.toString(),
          '<tspan', u.ATTRS_NUM, '>',
            Strings.toString(affix.value),
          '</tspan>',
          statmodNameSplitRight.toString(),
        '</text>'
      );
    }

    // prettier-ignore
    string memory output = string.concat(
      u.START,
      '<text', u.ATTRS_HEADER_TYPE, 'y="5">',
        lootNameLines[0],
      '</text>',
      '<text', u.ATTRS_HEADER_TYPE, 'y="25">',
        lootNameLines[1],
      '</text>',
      '<text', u.ATTRS_HEADER_TYPE, 'y="45">',
        lootNameLines[2],
      '</text>',
      affixesSvg,
      u.END
    );

    // TODO better description? bg color?
    // prettier-ignore
    return Base64.encode(abi.encodePacked(
      '{"name": "', lootName, '",',
      '"description": "Loot NFT",',
      '"attributes": [',
        affixesAttrs,
        '{'
          '"trait_type": "Base",'
          '"value": "Loot"'
        '}'
      '],'
      '"background_color": "#1e1e1e",',
      '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'
    ));
  }

  // Checks each line and appends to the first non-full line, or the last one if all are full
  // (svg text can't wrap)
  function pickAndAppendLootNameLine(string[3] memory lootNameLines, string memory appendNaming) internal pure {
    uint256 maxLineLength = 40;
    uint256 lastIndex = lootNameLines.length - 1;

    for (uint256 i; i < lootNameLines.length; i++) {
      uint256 newLineLength = bytes(lootNameLines[i]).length + bytes(appendNaming).length;

      if (newLineLength < maxLineLength || i == lastIndex) {
        string memory space = bytes(lootNameLines[i]).length == 0 ? "" : " ";
        lootNameLines[i] = string.concat(lootNameLines[i], space, appendNaming);
        return;
      }
    }
  }

  function getOrderedAffixes(bytes32 lootEntity) internal view returns (AffixData[] memory orderedAffixes) {
    bytes32[] memory affixEntities = LootAffixes.get(lootEntity);
    AffixData[] memory affixData = new AffixData[](affixEntities.length);
    for (uint256 i; i < affixEntities.length; i++) {
      affixData[i] = Affix.get(affixEntities[i]);
    }

    AffixData[][3] memory nestedOrderedAffixes = [
      filterAffixes(affixData, AffixPartId.PREFIX),
      filterAffixes(affixData, AffixPartId.IMPLICIT),
      filterAffixes(affixData, AffixPartId.SUFFIX)
    ];

    uint256 resultLength;
    for (uint256 i; i < nestedOrderedAffixes.length; i++) {
      resultLength += nestedOrderedAffixes[i].length;
    }
    orderedAffixes = new AffixData[](resultLength);
    uint256 resultIndex = 0;
    for (uint256 i; i < nestedOrderedAffixes.length; i++) {
      for (uint256 j; j < nestedOrderedAffixes[i].length; j++) {
        orderedAffixes[resultIndex] = nestedOrderedAffixes[i][j];
        resultIndex++;
      }
    }
  }

  function filterAffixes(
    AffixData[] memory affixData,
    AffixPartId affixPartId
  ) internal pure returns (AffixData[] memory filteredAffixes) {
    uint256 count = 0;
    for (uint256 i; i < affixData.length; i++) {
      if (affixData[i].partId == affixPartId) {
        count++;
      }
    }

    filteredAffixes = new AffixData[](count);
    uint256 resultIndex = 0;
    for (uint256 i; i < affixData.length; i++) {
      if (affixData[i].partId == affixPartId) {
        filteredAffixes[resultIndex] = affixData[i];
        resultIndex++;
      }
    }

    return filteredAffixes;
  }
}
