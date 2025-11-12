import { useState, useEffect } from "react";
import { fetchNui } from "../utils/fetchNui";
import { useNuiEvent } from "@/hooks/useNuiEvent";

export const WelcomeBack = () => {
  const [visible, setVisible] = useState(false);
  const [name, setName] = useState("");

  useNuiEvent('showWelcome', (data: { visible: boolean; name: string }) => {
    console.log('showWelcome dwadw aawda', JSON.stringify(data));
    setVisible(data.visible);
    if (data.name) setName(data.name);
  });

  useNuiEvent('hideWelcome', () => {
    setVisible(false);
  });

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Enter" && visible) {
        setVisible(false);
        fetchNui("closeWelcomeScreen");
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [visible]);

  if (!visible) return null;

  return (
    <main
      className="fixed grid w-screen h-screen place-items-center bg-black/80 animate-fadein"
      tabIndex={-1}
      aria-modal="true"
      role="dialog"
    >
      <div className="flex flex-col items-center gap-4 text-[#e9c896] uppercase animate-scalein">
        <img src="https://i.ibb.co/XxZVtBdn/image.png" alt="Server Logo" className="object-cover w-32 h-32 animate-fadein" />
        <div className="space-y-2 text-center">
          <h1 className="text-3xl font-semibold">Welcome Back, <span className="text-[#d37f21]">{name}</span></h1>
          <div className="text-gray-300 uppercase animate-pulse">Press <span className="text-[#d37f21]">[Enter]</span> to continue</div>
        </div>
      </div>
    </main>
  );
};
