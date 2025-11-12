import { useEffect, useState } from "react";
import { fetchNui } from "../utils/fetchNui";
import { useNuiEvent } from "@/hooks/useNuiEvent";

interface Location {
  name: string;
  desc: string;
  id: string;
}

export const SpawnSelector = () => {
  const handleLocationClick = (loc: Location) => {
    setConfirmLocation(loc);
  };

  const handleConfirm = () => {
    if (confirmLocation) {
      fetchNui("spawnAtLocation", { location: confirmLocation.id });
      setVisible(false);
      setConfirmLocation(null);
    }
  };

  const handleCancel = () => {
    setConfirmLocation(null);
  };

  const [visible, setVisible] = useState(false);
  const [locations, setLocations] = useState<Location[]>([]);
  const [loading, setLoading] = useState(false);
  const [confirmLocation, setConfirmLocation] = useState<Location | null>(null);

  useNuiEvent('showSpawnSelector', ({ show, locations }: { show: boolean, locations: Location[] }) => {
    setVisible(show);
    setLocations(locations);
    setLoading(false);
  });

  useNuiEvent('hideSpawnSelector', () => {
    setVisible(false);
    setConfirmLocation(null);
  });

  if (!visible) return null;

  return (
    <main
      className="fixed grid w-screen h-screen place-items-center bg-black/80 animate-fadein"
      tabIndex={-1}
      aria-modal="true"
      role="dialog"
    >
      <div className="flex flex-col items-center gap-6 text-white animate-scalein">
        <h1 className="text-2xl font-bold uppercase" style={{ color: "#e9c896" }}>Spawn Selector</h1>
        {loading ? (
          <div className="w-[320px] flex flex-col items-center justify-center gap-2 animate-fadein">
            <div className="loader" style={{ marginTop: 32 }}></div>
            <div className="mt-2 text-base text-[#d37f21]">Loading spawns...</div>
          </div>
        ) : (
          <>
            <div className="w-[320px] space-y-1">
              {locations.map((loc) => {
                console.log(loc.id);
                const isSelected = confirmLocation && confirmLocation.name === loc.name || false;
                return (
                  <div
                    key={loc.id}
                    className={`flex items-center bg-[#23232b] px-4 py-3 hover:bg-[#2c2c36] cursor-pointer transition animate-cardin border border-white/5 ${isSelected ? 'bg-[#2c2c36] text-[#e9c896]' : ''} `}
                    onClick={() => handleLocationClick(loc)}
                    tabIndex={0}
                    role="button"
                    aria-pressed={isSelected}
                    onKeyDown={e => (e.key === 'Enter' || e.key === ' ') && handleLocationClick(loc)}
                    style={{ borderRadius: 0 }}
                  >
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="mr-3"><path d="M21 10c0 6.075-9 13-9 13S3 16.075 3 10a9 9 0 1 1 18 0z" /><circle cx="12" cy="10" r="3" /></svg>
                    <span>{loc.name}</span>
                  </div>
                );
              })}
            </div>
            <div className="flex w-full gap-2">
              <button
                className={`flex items-center w-full justify-center gap-2 px-3 py-2 font-semibold text-black transition-all duration-150 ${confirmLocation ? 'bg-[#e9c896] text-black hover:bg-[#ffd5a6]' : 'bg-gray-600/25 text-gray-300 cursor-not-allowed border border-[#444]'}`}
                onClick={handleConfirm}
                disabled={!confirmLocation}
                aria-disabled={!confirmLocation}
                autoFocus={!!confirmLocation}
                style={{ borderRadius: 0 }}
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12" /></svg>
                Confirm
              </button>
              <button
                className="flex items-center justify-center w-full gap-2 px-3 py-2 font-semibold text-white transition-all duration-150 bg-gray-700 hover:bg-gray-800 disabled:bg-gray-600/25"
                onClick={handleCancel}
                disabled={!confirmLocation}
                aria-disabled={!confirmLocation}
                style={{ borderRadius: 0 }}
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" /></svg>
                Cancel
              </button>
            </div>
          </>
        )}
      </div>
    </main>
  );
}
