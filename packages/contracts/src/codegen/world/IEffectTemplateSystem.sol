// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { EffectTemplateData } from "../../namespaces/effect/codegen/tables/EffectTemplate.sol";

/**
 * @title IEffectTemplateSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IEffectTemplateSystem {
  error EffectTemplateSystem_LengthMismatch();
  error EffectTemplateSystem_InvalidStatmod(bytes32 statmodEntity);

  function effect__setEffectTemplate(bytes32 applicationEntity, EffectTemplateData memory effectTemplateData) external;

  function effect__setEffectTemplateFromAffixes(bytes32 applicationEntity, bytes32[] memory affixEntities) external;
}
