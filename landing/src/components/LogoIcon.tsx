import React from 'react';

interface LogoIconProps {
  className?: string;
}

export const LogoIcon: React.FC<LogoIconProps> = ({ className = 'w-6 h-6' }) => {
  return (
    <img
      src="/app/assets/logo.png"
      alt="VacanSee Logo"
      className={className}
    />
  );
};
