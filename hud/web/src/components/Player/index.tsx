
import { useState } from "react";
import { useNuiEvent } from "../../hooks/useNuiEvent";

import { Bar } from "./bar";

import { statuses as getStatusConfigs } from "@/constants/statuses";
import { type Statuses, type StatusConfig } from "@/interfaces/status";
import { Postal } from "./Postal";
import { Compass } from "./Compass";
import { AOP } from "../AOP";

export const PlayerStatus = ({ visible, postal, compass, aop, inVehicle, minimap }: { visible: boolean; postal: any; compass: any; aop: any; inVehicle: boolean; minimap: any; }) => {
    const [statuses, setStatuses] = useState<Statuses>({
        health: 100,
        armor: 0,
        oxygen: 100
    });

    useNuiEvent('setStatuses', setStatuses);
    const statusConfigs = getStatusConfigs();

    let leftClass = '';
    if (minimap) {
        leftClass = 'left-[21.4rem]';
    } else {
        leftClass = inVehicle ? 'left-[21.4rem]' : 'left-[2.4rem]';
    }

    return (
        <div className={`absolute space-y-4 transition-all ease-in-out duration-500 bottom-9 ${visible ? 'slide-up' : 'slide-down'} ${leftClass}`}>
            <div className="space-y-1">
                {postal && compass.street ? (
                    <>
                        <AOP data={aop} visible={visible} />
                        <Postal postal={postal} />
                        <Compass
                            heading={compass.heading}
                            street={compass.street}
                            crossStreet={compass.crossStreet}
                        />
                    </>
                ) : null}
            </div>
            <div className="flex flex-col gap-1 w-[180px]">
                {statusConfigs.map((cfg: StatusConfig) => {
                    if (!cfg.showCondition()) return null;
                    let value = 0;
                    if (cfg.key === 'health' || cfg.key === 'armor') {
                        value = typeof statuses[cfg.key as keyof Statuses] === 'number' ? (statuses[cfg.key as keyof Statuses] as number) : 0;
                    }
                    if (cfg.key === 'armor' && value === 0) return null;
                    return (
                        <Bar
                            key={cfg.key}
                            value={value}
                            label={cfg.label}
                        />
                    );
                })}
            </div>
        </div>
    );
};
