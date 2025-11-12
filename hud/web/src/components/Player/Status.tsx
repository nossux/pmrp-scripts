interface Props {
  value: number;
  color: string;
  gradient: string;
  icon: any;
}

export const StatusBar = ({
  value,
  color,
  gradient,
  icon,
}: Props) => {
  const percentage = Math.max(0, Math.min(100, value));
  const strokeWidth = 3;
  const radius = (32 - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (percentage / 100) * circumference;

  return (
    <div
      className="relative flex items-center justify-center rounded-full"
      style={{ width: 32, height: 32 }}
    >
      <svg
        width={32}
        height={32}
        className="absolute top-0 left-0"
        style={{ transform: "rotate(-90deg)" }}
      >
        <circle
          cx={32 / 2}
          cy={32 / 2}
          r={radius}
          stroke="rgba(255,255,255,0.15)"
          strokeWidth={strokeWidth}
          fill="none"
        />
        <circle
          cx={32 / 2}
          cy={32 / 2}
          r={radius}
          stroke={`url(#gradient)`}
          strokeWidth={strokeWidth}
          fill="none"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
        />
        <defs>
          <linearGradient id="gradient" x1="0" y1="0" x2={32} y2={32}>
            <stop offset="0%" stopColor={color} />
            <stop offset="100%" stopColor={gradient} />
          </linearGradient>
        </defs>
      </svg>
      {icon && (
        <i
          className={`${icon} text-white text-xs drop-shadow-sm`}
          style={{
            position: "absolute",
            left: "50%",
            top: "50%",
            transform: "translate(-50%, -50%)",
            zIndex: 1,
            textShadow: "0 1px 2px #000",
          }}
        />
      )}
    </div>
  );
};
