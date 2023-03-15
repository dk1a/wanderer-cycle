import CustomButton from "../UI/Button/CustomButton";

export default function Party() {
  const tables = [{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }, { id: 5 }, { id: 6 }, { id: 7 }, { id: 8 }, { id: 9 }];

  // const onSeat = () => {
  //
  // }
  return (
    <div className="h-full w-full">
      <h3 className="text-2xl text-dark-comment mr-2">{"// party"}</h3>
      <div className="grid grid-cols-3 w-full h-full items-center">
        {tables.map((id) => (
          <div
            key={null}
            className="text-center border border-dark-400 flex flex-col justify-center items-center w-1/2 h-1/2"
          >
            <div className="border border-dark-400 text flex justify-center items-center">name</div>
            <CustomButton>take a seat</CustomButton>
          </div>
        ))}
      </div>
    </div>
  );
}
