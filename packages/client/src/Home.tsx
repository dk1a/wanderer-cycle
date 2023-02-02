import { useMUD } from "./MUDContext";

export const Home = () => {
  const {
    components: { /*ActiveGuise, GuisePrototype, LoadingState*/ },
    playerEntity,
  } = useMUD();

  return (
    <div>
      home placeholder
    </div>
  );
};
