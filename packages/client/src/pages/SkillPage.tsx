import CycleInfo from "../components/info/CycleInfo";
import SkillList from "../components/SkillList";
import { useWandererContext } from "../contexts/WandererContext";
import Wanderer from "../components/Wanderer";
import { useWandererEntities } from "../mud/hooks/useWandererEntities";

const SkillPage = () => {
  const { selectedWandererEntity } = useWandererContext();
  const wandererEntities = useWandererEntities();

  return (
    <section className="flex justify-center">
      {selectedWandererEntity === undefined ? (
        <div>
          <h3 className="m-10 text-2xl font-bold text-dark-comment">{"//select a wanderer"}</h3>
          <div className="flex justify-around">
            <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2 justify-around">
              {wandererEntities.map((wandererEntity) => (
                <Wanderer key={wandererEntity} wandererEntity={wandererEntity} />
              ))}
            </div>
          </div>
        </div>
      ) : (
        <div className="flex justify-center">
          <CycleInfo />
          <SkillList />
        </div>
      )}
    </section>
  );
};

export default SkillPage;
