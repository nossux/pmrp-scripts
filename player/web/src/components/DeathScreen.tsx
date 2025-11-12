

import React, { useState, useEffect } from "react";
import { useNuiEvent } from "@/hooks/useNuiEvent";

const formatTime = (seconds: number): string => {
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
};

export const DeathScreen: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [timer, setTimer] = useState(0);
  const [canRevive, setCanRevive] = useState(false);
  const [reviveProgress, setReviveProgress] = useState(0);

  useNuiEvent('showDeath', (data: { timer: number }) => {
    setVisible(true);
    setTimer(data?.timer ?? 0);
    setCanRevive(false);
    setReviveProgress(0);
  });

  useNuiEvent('hideDeath', () => {
    setVisible(false);
    setTimer(0);
    setCanRevive(false);
    setReviveProgress(0);
  });

  useNuiEvent('updateTimer', (data: { timer: number; canRevive: boolean }) => {
    setTimer(data.timer);
    setCanRevive(data.canRevive);
  });

  useNuiEvent('updateReviveProgress', (data: { progress: number }) => {
    setReviveProgress(data.progress);
  });

  if (!visible) return null;

  return (
    <main
      className="fade-in"
      style={{
        width: '100vw',
        height: '100vh',
        display: "grid",
        placeItems: "center",
        background: `radial-gradient(circle at 30% 20%, rgba(239, 68, 68, 0.4) 0%, rgba(239, 68, 68, 0.15) 40%, transparent 70%), radial-gradient(circle at 70% 80%, rgba(239, 68, 68, 0.3) 0%, transparent 50%), rgba(0, 0, 0, 0.6)`,
        position: 'fixed',
        top: 0,
        left: 0,
        zIndex: 9999
      }}>
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background: `linear-gradient(135deg, 
                                rgba(220, 38, 38, 0.15) 0%, 
                                rgba(220, 38, 38, 0.05) 50%, 
                                transparent 100%
                            )`,
        }}
      />
      <main className="flex flex-col items-center gap-6 text-white">
        <svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="m12.5 17-.5-1-.5 1h1z" />
          <path d="M15 22a1 1 0 0 0 1-1v-1a2 2 0 0 0 1.56-3.25 8 8 0 1 0-11.12 0A2 2 0 0 0 8 20v1a1 1 0 0 0 1 1z" />
          <circle cx="15" cy="12" r="1" />
          <circle cx="9" cy="12" r="1" />
        </svg>
        <h1 className="text-3xl font-bold">You are Dead</h1>
        {!canRevive ? (
          <div className="text-center">
            <div className="mb-2 font-mono text-2xl text-white">{formatTime(timer)}</div>
            <span className="text-gray-300">Wait for the timer to expire before you can revive</span>
          </div>
        ) : (
          <div className="text-center transition-all">
            <div className="mb-6">
              <span className="block mb-4 text-lg text-white">Hold to Revive</span>
              <div className="relative w-24 h-24 mx-auto">
                <div className="absolute inset-0 bg-gray-800 bg-opacity-50 border-2 border-gray-500 rounded-full"></div>
                <div
                  className="absolute inset-0 overflow-hidden transition-all duration-100 ease-out rounded-full"
                  style={{
                    background: `conic-gradient(from -90deg, white ${reviveProgress * 360}deg, transparent 0deg)`,
                    clipPath: 'circle(50%)'
                  }}
                ></div>
                <div className="absolute bg-gray-800 bg-opacity-50 rounded-full inset-2"></div>
                <div className="absolute inset-0 flex items-center justify-center">
                  <span className="z-10 text-2xl font-bold text-white">E</span>
                </div>
              </div>
              {reviveProgress > 0 && (
                <div className="mt-4">
                  <div className="text-sm text-gray-300">
                    {Math.round(reviveProgress * 100)}%
                  </div>
                </div>
              )}
            </div>
          </div>
        )}
      </main>
    </main>
  );
};
