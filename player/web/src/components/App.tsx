import { WelcomeBack } from "./WelcomeBack";
import { DeathScreen } from "./DeathScreen";
import { SpawnSelector } from "./SpawnSelector";

export const App = () => {
  return (
    <>
      <DeathScreen />
      <WelcomeBack />
      <SpawnSelector />
    </>
  );
};
