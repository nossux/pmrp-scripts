export interface Statuses {
  health: number;
  armor: number;
  oxygen: number;
}

export interface StatusConfig {
  key: keyof Statuses;
  icon?: string;
  label: string;
  showCondition: () => boolean;
}
