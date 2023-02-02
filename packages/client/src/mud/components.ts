import { defineComponent, Type } from "@latticexyz/recs";
import {
  defineNumberComponent,
  defineStringComponent,
} from "@latticexyz/std-client";
import { world } from "./world";

export const components = {
  Name: defineStringComponent(world, {
    metadata: {
      contractId: "component.Name",
    },
  }),

  GuisePrototype: defineComponent(
    world,
    {
      gainMul: Type.NumberArray,
      levelMul: Type.NumberArray,
    },
    {
      id: "GuisePrototype",
      metadata: { contractId: "component.GuisePrototype" },
    }
  ),
  ActiveGuise: defineNumberComponent(world, {
    metadata: {
      contractId: "component.ActiveGuise",
    },
  }),
  GuiseSkills: defineComponent(
    world,
    {
      width: Type.NumberArray,
    },
    {
      id: "GuiseSkills",
      metadata: { contractId: "component.GuiseSkills" },
    }
  ),
};

export const clientComponents = {};
