import { StatusConfig } from '@/interfaces/status';

export const statuses = (): StatusConfig[] => [
  {
    key: 'health',
    label: 'Health',
    showCondition: () => true,
  },
  {
    key: 'armor',
    label: 'Armor',
    showCondition: () => true,
  },
];
