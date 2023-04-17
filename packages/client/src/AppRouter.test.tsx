import { render, screen } from "@testing-library/react";
import "@testing-library/jest-dom/extend-expect";
import { WandererProvider } from "./contexts/WandererContext";
import { Layout } from "./AppRouter";

describe("Layout component", () => {
  it("should render the navigation bar with correct links", () => {
    render(
      <WandererProvider>
        <Layout />
      </WandererProvider>
    );

    expect(screen.getByText("Maps")).toBeInTheDocument();
    expect(screen.getByText("Inventory")).toBeInTheDocument();
    expect(screen.getByText("Skills")).toBeInTheDocument();
    expect(screen.getByText("Cycle")).toBeInTheDocument();
    expect(screen.getByText("Wanderer Select")).toBeInTheDocument();
  });

  it("should render the GitHub and Discord links in the navigation bar", () => {
    render(
      <WandererProvider>
        <Layout />
      </WandererProvider>
    );

    expect(screen.getByText("github")).toHaveAttribute("href", "https://github.com/dk1a/wanderer-cycle");
    expect(screen.getByText("discord")).toHaveAttribute("href", "https://discord.gg/9pX3h53VnX");
  });

  it("should toggle the wanderer mode when the button is clicked", () => {
    const toggleWandererModeMock = jest.fn();

    render(
      <WandererProvider>
        <Layout />
      </WandererProvider>
    );

    const toggleButton = screen.getByText("void");
    toggleButton.click();
    expect(toggleWandererModeMock).toHaveBeenCalledTimes(1);

    toggleButton.click();
    expect(toggleWandererModeMock).toHaveBeenCalledTimes(2);
  });
});
