export const Compass = ({
  heading,
  street,
  crossStreet,
}: {
  heading: number;
  street: string;
  crossStreet: string;
}) => {
  const getCardinalDirection = (heading: number): string => {
    const directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
    const index = Math.round(heading / 45) % 8;
    return directions[index];
  };
  const direction = getCardinalDirection(heading);

  return (
    <div
      className={`flex items-center gap-2 text-xs font-medium text-white drop-shadow-sm ${heading || street || crossStreet ? "slide-up" : "slide-down"}`}
    >
      <span>{direction}</span>
      <span>|</span>
      <span>{street}</span>
      {crossStreet && (
        <>
          <span>x</span>
          <span>{crossStreet}</span>
        </>
      )}
    </div>
  );
};
