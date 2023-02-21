import { forwardRef, Fragment } from "react";

interface ModifierNameProps {
  name: string;
  value: string | number;
  className?: string;
}

const ModifierName = forwardRef<HTMLDivElement, ModifierNameProps>(({ name, value, className }, ref) => {
  const nameParts = name.split("#");

  return (
    <div ref={ref} className="flex flex-wrap">
      {nameParts.map((namePart, index) => (
        <div key={namePart} className="">
          {index !== 0 && <span className="text-dark-number text-[14px]">{value}</span>}
          <span className="text-dark-string text-[14px]">{namePart}</span>
        </div>
      ))}
    </div>
  );
});
ModifierName.displayName = "ModifierName";

export default ModifierName;
