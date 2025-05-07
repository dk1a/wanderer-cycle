import { ELE_STAT, getEnumValues } from "contracts/enums";
import {
  Elemental,
  eleStatColorClasses,
  eleStatNames,
} from "../../mud/utils/elemental";
import { useMemo } from "react";

type ElementalNumbersProps = {
  data: Elemental;
};

export function ElementalNumbers({ data }: ElementalNumbersProps) {
  const eleStatsWithData = useMemo(() => {
    return getEnumValues(ELE_STAT).filter((eleStat) => data[eleStat] > 0);
  }, [data]);

  return (
    <>
      {eleStatsWithData.map((eleStat) => (
        <span
          key={eleStat}
          title={eleStatNames[eleStat]}
          className={eleStatColorClasses[eleStat]}
        >
          {" "}
          {data[eleStat]} {eleStatNames[eleStat]}{" "}
        </span>
      ))}
    </>
  );
}
