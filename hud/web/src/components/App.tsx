import { FC, useState } from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { debugData } from "@/utils/debugData";
import { isEnvBrowser } from "@/utils/misc";
import { PlayerStatus } from "./Player";
import { Vehicle } from "./Vehicle";
import { Watermark } from "./Watermark";
import { SpeedLimits } from "./Vehicle/SpeedLimits";

debugData([
  {
    action: "setVisible",
    data: true,
  },
  {
    action: "setStatuses",
    data: {
      health: 85,
      armor: 60,
      oxygen: 50,
    },
  },
  {
    action: "setInVehicle",
    data: true,
  },
  {
    action: "updateVehicle",
    data: {
      speed: 45,
      fuel: 75,
      engine: 95,
      gear: 3,
      seatbelt: false,
    },
  },
  { action: "setPostal", data: { code: "1234", dist: 50 } },
  {
    action: "setCompass",
    data: { heading: 270, street: "Main St", crossStreet: "2nd Ave" },
  },
  {
    action: "setAOP",
    data: { aop: "Los Santos", peacetime: true },
  },
]);

export const App: FC = () => {
  const [visible, setVisible] = useState<boolean>(false);
  useNuiEvent<boolean>("setVisible", (isVisible: boolean) =>
    setVisible(isVisible)
  );

  const [minimap, setMinimap] = useState<boolean>(false);
  const [inVehicle, setInVehicle] = useState<boolean>(false);
  useNuiEvent<{ isInVehicle: boolean; minimap: boolean }>("setInVehicle", (data) => {
    setInVehicle(data.isInVehicle);
    setMinimap(data.minimap);
  });

  const [postal, setPostal] = useState<{ code: string; dist: number } | null>(
    null
  );
  useNuiEvent("setPostal", (newPostal: { code: string; dist: number } | null) =>
    setPostal(newPostal)
  );

  const [compass, setCompass] = useState<{
    heading: number;
    street: string;
    crossStreet: string;
  }>({
    heading: 0,
    street: "",
    crossStreet: "",
  });

  useNuiEvent(
    "setCompass",
    (newCompass: { heading: number; street: string; crossStreet: string }) =>
      setCompass(newCompass)
  );

  const [aop, setAop] = useState<{
    aop: string;
    peacetime: boolean;
    priority: any;
  } | null>(null);

  useNuiEvent(
    "setAOP",
    (newAOP: { aop: string; peacetime: boolean; priority: any }) => setAop(newAOP));

  return (
    <main
      style={
        isEnvBrowser()
          ? {
            backgroundImage: "url(https://i.imgur.com/C5uyEx2.jpeg)",
            backgroundSize: "cover",
            width: "100vw",
            height: "100vh",
            top: 0,
            left: 0,
          }
          : {}
      }
    >
      <Watermark />
      <PlayerStatus visible={visible} postal={postal} compass={compass} aop={aop} inVehicle={inVehicle} minimap={minimap} />
      <Vehicle inVehicle={inVehicle} />
      <SpeedLimits />
    </main>
  );
};
