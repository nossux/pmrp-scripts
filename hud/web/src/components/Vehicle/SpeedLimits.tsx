import React, { useState } from "react";
import { useNuiEvent } from "@/hooks/useNuiEvent";

const getSpeedLimitImage = (speed: number | undefined): string | undefined => {
    if (!speed) return undefined;
    return `images/speed_limits/${speed}.png`;
};

export const SpeedLimits: React.FC = () => {
    const [visible, setVisible] = useState(false);
    const [road, setRoad] = useState<string>("");
    const [speed, setSpeed] = useState<number | undefined>(undefined);

    useNuiEvent("show", () => {
        setVisible(true);
    });

    useNuiEvent("hide", () => {
        setVisible(false);
        setRoad("");
        setSpeed(undefined);
    });

    useNuiEvent("setlimit", (data: { speed: number }) => {
        console.log(data.speed)
        setSpeed(typeof data.speed === "number" ? data.speed : undefined);
    });

    useNuiEvent("setroad", (data: { road: string }) => {
        setRoad(data.road);
    });

    if (!visible) return null;

    const imageSrc = getSpeedLimitImage(speed);

    return (
        <div className={`absolute bottom-36 left-8 ${visible && speed ? "slide-up" : "slide-down"}`}>
            <img className="w-12" src={imageSrc} alt={`Speed Limit ${speed}`} />
        </div>
    );
};