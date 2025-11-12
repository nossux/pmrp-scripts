export const Postal: React.FC<{
  postal: { code: string; dist: number } | null;
}> = ({ postal }) => {
  return (
    <div
      className={`${
        postal !== null ? "slide-up" : "slide-down"
      } text-white text-xs drop-shadow-sm`}
    >
      {postal && (
        <div>
          <span>Nearest Postal </span>
          <span className="font-medium text-gray-300">
            {postal.code} ({postal.dist}m)
          </span>
        </div>
      )}
    </div>
  );
};
