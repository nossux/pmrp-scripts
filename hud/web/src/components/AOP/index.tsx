import React from 'react';

interface AOPData {
  aop: string;
  peacetime: boolean;
  priority: {
    enabled: boolean;
    name: string;
  };
}

interface AOPProps {
  data: AOPData;
  visible: boolean;
}

export const AOP: React.FC<AOPProps> = ({ data, visible }) => {
  if (!data) return null;
  return (
    <div className={`mb-4 text-xs text-white drop-shadow-sm ${visible ? "slide-up" : "slide-down"}`}>
      <div className="flex flex-col gap-1">
        <div>
          <span>Priority</span> <span className='text-gray-300'>{data.priority?.enabled ? data.priority.name : "Normal"}</span>
        </div>
        <div>
          <span>AOP</span> <span className='text-gray-300'>{data.aop}</span>
        </div>
        <div>
          <span>Peacetime</span>
          <span className='text-gray-300'>
            {data.peacetime ? " Enabled" : " Disabled"}
          </span>
        </div>
      </div>
    </div>
  );
};
