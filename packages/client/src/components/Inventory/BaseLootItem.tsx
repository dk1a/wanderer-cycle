import { TokenData } from "../../utils/tokenBases";
import { ReactNode, useMemo } from "react";
import { GetJsonResult } from "../../utils/jsonFromUri";
import { useWalletsLootContext } from "../../contexts/WalletsLootContext";

type BaseLootItemArgs = {
  tokenData: TokenData;
  showSymbol: boolean;
  json?: GetJsonResult;
  className?: string;
  children?: ReactNode;
};

export default function BaseLootItem({ tokenData, showSymbol, json, className, children }: BaseLootItemArgs) {
  const { accounts } = useWalletsLootContext();
  // TODO make symbol also trigger popup on click that allows arbitrary transfers?
  const symbolSpan = useMemo(() => {
    if (!showSymbol) return false;
    const symbol = accounts.find(({ account }) => account === tokenData.account)?.symbol ?? "?";
    return <span className="text-dark-control mr-1">{symbol}</span>;
  }, [showSymbol, accounts, tokenData]);

  const balanceSpan = useMemo(() => {
    if (!tokenData.balance.gt(1)) return false;
    return (
      <span className="font-semibold ml-1">
        (<span className="text-dark-number">{tokenData.balance.toString()}</span>)
      </span>
    );
  }, [tokenData]);

  return (
    <div className={`flex flex-col w-48 box-border overflow-hidden border border-dark-400 ${className ?? ""}`}>
      {json ? (
        <object data={json?.image} className="w-48 h-48 ml-[-1px]" />
      ) : (
        <div className="w-48 h-48 text-dark-400 overflow-wrap-bw">{tokenData.tokenId.toHexString()}</div>
      )}

      <div className="flex flex-wrap w-48 gap-x-2 pl-2">
        {(symbolSpan || balanceSpan) && (
          <div>
            {symbolSpan}
            {tokenData.balance.gt(1) && (
              <span className="font-semibold ml-1">
                (<span className="text-dark-number">{tokenData.balance.toString()}</span>)
              </span>
            )}
          </div>
        )}

        {children}
      </div>
    </div>
  );
}
