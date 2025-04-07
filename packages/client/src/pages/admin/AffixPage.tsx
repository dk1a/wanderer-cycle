import { useMemo, useState } from "react";
import { Table } from "../../components/utils/Table/Table";
import {
  formatEntity,
  formatZeroTerminatedString,
} from "../../mud/utils/format";
import { mudTables, useStashCustom } from "../../mud/stash";
import { getRecords } from "@latticexyz/stash/internal";

const AffixPage = () => {
  const affixPrototypes = useStashCustom((state) => {
    return Object.values(
      getRecords({
        state,
        table: mudTables.affix__AffixPrototype,
      }),
    );
  });

  const [sortConfig, setSortConfig] = useState<{
    key: string;
    direction: "asc" | "desc";
  } | null>(null);

  const handleSort = (key: string) => {
    setSortConfig((prev) => {
      if (prev?.key === key) {
        return { key, direction: prev.direction === "asc" ? "desc" : "asc" };
      }
      return { key, direction: "asc" };
    });
  };

  const sortedAffixPrototypes = useMemo(() => {
    return affixPrototypes.sort((a, b) => {
      if (!sortConfig) return 0;
      const valueA = a[sortConfig.key] ?? "";
      const valueB = b[sortConfig.key] ?? "";

      if (valueA < valueB) return sortConfig.direction === "asc" ? -1 : 1;
      if (valueA > valueB) return sortConfig.direction === "asc" ? 1 : -1;
      return 0;
    });
  }, [affixPrototypes, sortConfig]);

  const columns = [
    { key: "entity", label: "entity", cellClassName: "text-dark-number" },
    { key: "name", label: "name" },
    { key: "affixTier", label: "affixTier", cellClassName: "text-dark-number" },
    { key: "exclusiveGroup", label: "exclusiveGroup" },
  ];

  const data = sortedAffixPrototypes.map((affixPrototype) => {
    return {
      entity: (
        <span
          className="hover:underline cursor-pointer"
          onClick={() => navigator.clipboard.writeText(affixPrototype.entity)}
        >
          {formatEntity(affixPrototype.entity)}
        </span>
      ),
      name: affixPrototype.name,
      affixTier: affixPrototype.affixTier,
      exclusiveGroup: formatZeroTerminatedString(affixPrototype.exclusiveGroup),
    };
  });

  return (
    <section className="flex flex-col mx-5 md:mx-10">
      <h2 className="text-2xl text-dark-comment m-2">{"// AffixPrototype"}</h2>
      <div className="overflow-x-auto">
        <Table columns={columns} data={data} onSort={handleSort} />
      </div>
    </section>
  );
};

export default AffixPage;
