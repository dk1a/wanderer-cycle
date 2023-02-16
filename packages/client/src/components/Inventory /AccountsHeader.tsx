import { useMemo } from "react";
import Select, { SingleValue } from "react-select";
import { useWalletsLootContext } from "../../contexts/WalletsLootContext";
import { useGetModifiers } from "../../hooks/queries/useGetModifiers";
import { getReactSelectStyles } from "../../utils/misc";
import ButtonWithCheckbox from "../ButtonWithCheckbox";
import TransferAllButton from "./TransferAllButton";
import { useUrisJson } from "../../hooks/uri/useUriJson";

export type Option = SingleValue<{
  value: string;
  label: string;
}>;

interface AccountsHeaderProps {
  modSort: Option;
  setModSort: (value: Option) => void;
}

export default function AccountsHeader({ modSort, setModSort }: AccountsHeaderProps) {
  const { accounts, shownLootList } = useWalletsLootContext();
  const modifiers = useGetModifiers();

  const lootIds = useMemo(() => shownLootList?.map(({ tokenId }) => tokenId) ?? [], [shownLootList]);
  const jsonQueries = useUrisJson(lootIds);
  const usedModOptions = useMemo(() => {
    return modifiers.data
      ?.filter(({ id }) =>
        jsonQueries.some(({ data }) => data && data.affixes?.some(({ modifier_id }) => modifier_id === id))
      )
      .map(({ id, modifierData: { name } }) => ({
        value: id,
        label: name,
      }));
  }, [modifiers, jsonQueries]);

  const accountsHeader = useMemo(() => {
    return accounts
      .filter(({ description }) => description !== undefined)
      .map(({ account, name, description }) => {
        return {
          account,
          name,
          description,
        };
      });
  }, [accounts]);

  return (
    <div>
      <div className="mb-2">
        {accountsHeader.map(({ account, description }) => (
          <div key={account} className="text-dark-comment">
            {`// ${description as string}`}
          </div>
        ))}
      </div>

      <div className="flex space-x-2">
        <Select<Option>
          isDisabled={!usedModOptions}
          value={modSort}
          onChange={setModSort}
          options={usedModOptions}
          styles={getReactSelectStyles()}
          placeholder="Sort by..."
        />

        {accounts.map(({ account, include, toggleInclude, includeText }) => (
          <ButtonWithCheckbox key={account} checked={include} onClick={toggleInclude} text={includeText} />
        ))}

        {accountsHeader.map(({ account, name }) => (
          <TransferAllButton key={account} toAccount={account} name={name} />
        ))}
      </div>
    </div>
  );
}
