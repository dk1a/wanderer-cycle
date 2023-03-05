import { defineQuery, QueryFragment } from "@latticexyz/recs";
import { useEffect, useMemo, useState } from "react";
import isEqual from "fast-deep-equal";
import { distinctUntilChanged, map } from "rxjs";

export function useEntityQuery(fragments: QueryFragment[], recomputeOnValueChange = false) {
  const stableFragments = useDeepMemo(fragments);
  const query = useMemo(() => defineQuery(stableFragments, { runOnInit: true }), [stableFragments]);
  const [entities, setEntities] = useState([...query.matching]);

  useEffect(() => {
    setEntities([...query.matching]);
    let observable = query.update$.pipe(map(() => [...query.matching]));
    if (!recomputeOnValueChange) {
      // recompute only on entity array changes
      observable = observable.pipe(distinctUntilChanged((a, b) => isEqual(a, b)));
    }
    const subscription = observable.subscribe((entities) => setEntities(entities));
    return () => subscription.unsubscribe();
  }, [query, recomputeOnValueChange]);

  return entities;
}

const useDeepMemo = <T>(currentValue: T): T => {
  const [stableValue, setStableValue] = useState(currentValue);

  useEffect(() => {
    if (!isEqual(currentValue, stableValue)) {
      setStableValue(currentValue);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentValue]);

  return stableValue;
};
