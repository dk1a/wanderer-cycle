import { defineQuery, QueryFragment } from "@latticexyz/recs";
import { useEffect, useMemo, useState } from "react";
import { distinctUntilChanged, map } from "rxjs";
import isEqual from "fast-deep-equal";

export function useEntityQuery(fragments: QueryFragment[]) {
  const stableFragments = useDeepMemo(fragments);
  const query = useMemo(() => defineQuery(stableFragments, { runOnInit: true }), [stableFragments]);
  const [entities, setEntities] = useState([...query.matching]);

  useEffect(() => {
    setEntities([...query.matching]);
    const subscription = query.update$
      .pipe(map(() => [...query.matching]))
      .pipe(distinctUntilChanged((a, b) => isEqual(a, b)))
      .subscribe((entities) => setEntities(entities));
    return () => subscription.unsubscribe();
  }, [query]);

  return entities;
}

export const useDeepMemo = <T>(currentValue: T): T => {
  const [stableValue, setStableValue] = useState(currentValue);

  useEffect(() => {
    if (!isEqual(currentValue, stableValue)) {
      setStableValue(currentValue);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentValue]);

  return stableValue;
};
