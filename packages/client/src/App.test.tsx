import { render, screen } from "@testing-library/react";
import { SyncState } from "@latticexyz/network";
import { useMUD } from "./mud/MUDContext";
import { App } from "./App";

jest.mock("./mud/MUDContext");

describe("App component", () => {
  beforeEach(() => {
    (useMUD as jest.Mock).mockReturnValue({
      components: { LoadingState: () => null },
      SingletonEntity: null,
    });
  });

  it("renders connecting message", () => {
    const loadingState = {
      state: SyncState.CONNECTING,
      msg: "Connecting",
      percentage: 25,
    };

    (useMUD as jest.Mock).mockReturnValue({
      components: { LoadingState: () => null },
      SingletonEntity: { some: "value" },
    });

    render(<App />);

    const message = screen.getByText(`${loadingState.msg} (${Math.floor(loadingState.percentage)}%)`);

    expect(message).toBeInTheDocument();
  });

  it("renders AppRouter component when sync state is live", () => {
    (useMUD as jest.Mock).mockReturnValue({
      components: { LoadingState: () => null },
      SingletonEntity: { some: "value" },
    });

    const loadingState = {
      state: SyncState.LIVE,
      msg: "",
      percentage: 100,
    };

    render(<App />);

    const appRouter = screen.getByTestId("app-router");

    expect(appRouter).toBeInTheDocument();
  });
});
