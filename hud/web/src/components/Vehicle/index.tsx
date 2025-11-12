import { useMemo, useState } from 'react';
import { useNuiEvent } from '@/hooks/useNuiEvent';

interface VehicleData {
  fuel: number;
  speed: number;
  rpm: number;
  gear: number;
  engineHealth: number;
  headlights: boolean;
  engineLight: boolean;
  oilLight: boolean;
  batteryLight: boolean;
  seatbelt: boolean;
  cruise: boolean;
}

const warningIcons = [
  {
    key: 'engineLight',
    icon: 'fas fa-exclamation-triangle',
    title: 'Engine Warning',
  },
  {
    key: 'oilLight',
    icon: 'fas fa-oil-can',
    title: 'Oil Pressure',
  },
  {
    key: 'batteryLight',
    icon: 'fas fa-car-battery',
    title: 'Battery',
  },
];

const TOTAL_BARS = 24;
const MAX_RPM = 8000;

function getRpmBarColors(rpm: number) {
  const rpmRatio = Math.max(0, Math.min(1, rpm / MAX_RPM));
  return Array.from({ length: TOTAL_BARS }).map((_, idx) => {
    const barActive = idx < Math.round(rpmRatio * TOTAL_BARS);
    if (!barActive) return 'bg-white/30';

    const percent = idx / (TOTAL_BARS - 1);
    if (percent < 0.6) return 'bg-white';
    if (percent < 0.85) return 'bg-orange-400';
    return 'bg-red-500';
  });
}

const RpmBars: React.FC<{ rpm: number }> = ({ rpm }) => {
  const barColors = getRpmBarColors(rpm);
  return (
    <div className="flex flex-row gap-0.5 justify-end items-end w-full">
      {barColors.map((barColor, idx) => (
        <div
          key={idx}
          className={`h-4 w-1.5 rounded-sm transition-all duration-100 ${barColor}`}
        />
      ))}
    </div>
  );
};

export const Vehicle = ({ inVehicle, minimapAlwaysOn }: { inVehicle: boolean, minimapAlwaysOn?: boolean }) => {
  const [vehicleData, setVehicleData] = useState<VehicleData>({
    fuel: 50,
    speed: 123,
    rpm: 6000,
    gear: 1,
    engineHealth: 100,
    headlights: false,
    engineLight: false,
    oilLight: false,
    batteryLight: false,
    seatbelt: true,
    cruise: false,
  });

  useNuiEvent<Partial<VehicleData>>('updateVehicle', (data) =>
    setVehicleData((prev) => ({ ...prev, ...data }))
  );

  const roundedSpeed = Math.round(vehicleData.speed);

  const updateColors = (valueStr: string) => {
    return valueStr.split('').map((digit, index, arr) => {
      const isLeadingZero = arr.slice(0, index).every((d) => d === '0');
      return digit === '0' && isLeadingZero
        ? 'rgba(255, 255, 255, 0.5)'
        : 'rgba(255, 255, 255, 1)';
    });
  };

  const speedDisplay = useMemo(() => {
    const valueStr = roundedSpeed.toString().padStart(3, '0');
    const digits = [...valueStr];
    const colors = updateColors(valueStr);
    return { digits, colors };
  }, [roundedSpeed]);

  return (
    <div
      className={`absolute grid grid-cols-1 place-items-end gap-2 bottom-4 right-6 font-heading ${
        minimapAlwaysOn ? '' : (inVehicle ? 'slide-up' : 'slide-down')
      }`}
    >
      <section className="flex items-end space-x-4 h-fit">
        <div>
          <div className="font-sans text-xs font-medium text-white/60 text-end drop-shadow-sm">
            MP/H
          </div>
          <div className="flex text-center text-white text-7xl">
            {speedDisplay.digits.map((digit, index) => (
              <span
                key={index}
                className={`inline-block text-center transition-all duration-300 font-semibold w-[1ch] ${
                  vehicleData.cruise ? 'text-primary' : ''
                }`}
                style={{
                  color: !vehicleData.cruise ? speedDisplay.colors[index] : undefined,
                }}
              >
                {digit}
              </span>
            ))}
          </div>
        </div>

        <div className="flex items-center gap-4 font-sans">
          <div className="flex flex-col justify-between gap-2.5 text-xs text-white">
            <span
              className={
                vehicleData.fuel >= 90 ? 'text-white/60' : 'text-white'
              }
            >
              F
            </span>
            <span className="text-white drop-shadow-sm fas fa-gas-pump" />
            <span
              className={
                vehicleData.fuel >= 10 ? 'text-white/60' : 'text-white'
              }
            >
              E
            </span>
          </div>
          
          <div className="flex flex-col-reverse gap-1">
            {(() => {
              const TOTAL_BARS = 6;
              const activeBars = Math.min(
                TOTAL_BARS,
                Math.round((vehicleData.fuel / 100) * TOTAL_BARS)
              );

              let activeColor = 'bg-white';
              if (activeBars === 1) activeColor = 'bg-red-500';
              else if (activeBars === 2) activeColor = 'bg-orange-500';

              return [...Array(TOTAL_BARS)].map((_, index) => {
                const isActive = index < activeBars;
                return (
                  <div
                    key={index}
                    className={`h-1.5 w-4 rounded-sm border ${
                      isActive
                        ? `${activeColor} border-transparent`
                        : 'bg-white/10 border-white/5'
                    }`}
                  />
                );
              });
            })()}
          </div>
        </div>
      </section>

      <RpmBars rpm={vehicleData.rpm} />

      <section className="flex items-center gap-6 mt-2">
        {warningIcons.map(({ key, icon, title }) => (
          <span
            key={key}
            className="flex items-center justify-center"
            title={title}
          >
            <i
              className={`${icon} text-lg transition-all duration-300 ${
                vehicleData[key as keyof VehicleData]
                  ? 'text-white'
                  : 'text-white/25'
              }`}
            />
          </span>
        ))}
      </section>
    </div>
  );
};
