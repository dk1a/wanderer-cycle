import { forwardRef, Fragment } from "react";

interface ModifierNameProps {
  name: string;
  value: string | number;
  className?: string;
}

const ModifierName = forwardRef<HTMLDivElement, ModifierNameProps>(({ name, value, className }, ref) => {
  const nameParts = name.split("#");

  return (
    <div ref={ref} className={className}>
      {nameParts.map((namePart, index) => (
        <Fragment key={namePart}>
          {index !== 0 && <span className="text-dark-number">{value}</span>}
          <span className="text-dark-string">{namePart}</span>
        </Fragment>
      ))}
    </div>
  );
});
ModifierName.displayName = "ModifierName";

export default ModifierName;
