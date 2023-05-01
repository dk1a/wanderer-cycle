// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { UriUtils as u } from "./UriUtils.sol";

/*library LibUriEquipment {
    function json(uint256 id) internal view returns (string memory) {
        AppliedAffix[] memory affixes = LootStorage.getAffixes(id);
        require(
            affixes.length > 0 && affixes.length <= 3,
            'LibNames: invalid loot affix count'
        );
        uint128 tokenBase = LibSplitId.getTokenBase(id);

        // nameSplit is physical position of text, whereas nameParts are ordered by type
        string[3] memory nameSplit;
        // generic attributes for opensea etc
        string memory affixesAttrsStr;
        // non-standard array of affixes
        // (generic attributes can't represent them well - affixes have 4 datums: type, name, modName and value)
        string memory affixesCustomStr;
        // affix mods as svg text
        string memory modifiersUriStr;

        for (uint256 i; i < affixes.length; i++) {
            AppliedAffix memory affix = affixes[i];

            // npType is priority of existence (implicit can exist without prefix)
            NamingPartType npType;
            // placeIndex is placement in text (prefix goes before implicit)
            uint256 placeIndex;
            if (i == 0) {
                npType = NamingPartType.IMPLICIT;
                placeIndex = 1;
            } else if (i == 1) {
                npType = NamingPartType.PREFIX;
                placeIndex = 0;
            } else if (i == 2) {
                npType = NamingPartType.SUFFIX;
                placeIndex = 2;
            }

            string memory npTypeName = AffixNamingStorage.getTypeName(npType);

            nameSplit[placeIndex] = AffixNamingStorage.getPartName(
                affix.id,
                affix.variantTier,
                tokenBase,
                npType
            );

            string memory affixValueStr = Strings.toString(affix.mod.modifierValue);
            ModifierDataFull storage modData = ModifierStorage.modifierDataFull(affix.mod.modifierId);

            AffixData storage affixData = AffixStorage.getAffixData(affix.id);
            affixesAttrsStr = string.concat(affixesAttrsStr,
                '{'
                    '"trait_type": "', npTypeName, '",'
                    '"value": "', affixData.name, '"'
                '},'
                '{'
                    '"trait_type": "', modData.name, '",'
                    '"value": ', affixValueStr,
                '},'
            );

            string memory lastComma = i == affixes.length - 1 ? '' : ',';
            affixesCustomStr = string.concat(affixesCustomStr,
                '{'
                    '"trait_type": "', npTypeName, '",'
                    '"name": "', affixData.name, '",'
                    '"modifier_id": "', Strings.toHexString(uint32(affix.mod.modifierId), 4), '",'
                    '"modifier_name": "', modData.name, '",'
                    '"value": ', affixValueStr,
                '}',
                lastComma
            );

            modifiersUriStr = string.concat(modifiersUriStr,
                URI_TEXT_, 'x="10" y="', Strings.toString(40 * 4 + i * 30), '" ',
                URI_STRING_FILL_, ' style="font-size: 20px;">',
                    modData.nameSplitForValue[0],
                    URI_TSPAN_NUM,
                        affixValueStr,
                    '</tspan>',
                    modData.nameSplitForValue[1]
            );
        }

        string memory output = string.concat(
            URI_START,
            URI_TEXT_INIT_, 'y="40">',
                nameSplit[0],
            '</text>',
            URI_TEXT_INIT_, 'y="80">',
                nameSplit[1],
            '</text>',
            URI_TEXT_INIT_, 'y="120">',
                nameSplit[2],
            modifiersUriStr,
            URI_END
        );

        string memory name = string.concat(
            nameSplit[0], (bytes(nameSplit[0]).length > 0 ? ' ' : ''),
            nameSplit[1], (bytes(nameSplit[1]).length > 0 ? ' ' : ''),
            nameSplit[2]
        );
        // TODO better description?
        return Base64.encode(abi.encodePacked(
            '{"name": "', name, '",',
            '"description": "Equipment NFT",',
            '"attributes": [',
                affixesAttrsStr,
                '{'
                    '"trait_type": "Base",'
                    '"value": "Loot"'
                '}'
            '],'
            '"affixes": [',
                affixesCustomStr,
            '],'
            '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'
        ));
    }
}*/
