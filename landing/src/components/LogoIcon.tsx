import React from 'react';

interface LogoIconProps {
  className?: string;
}

export const LogoIcon: React.FC<LogoIconProps> = ({ className = 'w-6 h-6' }) => {
  return (
    <svg
      className={className}
      viewBox="0 0 24 24"
      strokeWidth={2}
      fill="none"
      stroke="currentColor"
      strokeLinecap="round"
      strokeLinejoin="round"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path d="M 12 2 L 3 9 L 3 22 L 9 22 L 9 14 L 15 14 L 15 22 L 21 22 L 21 9 Z" />
      <path d="M 12 2 L 12 12" />
    </svg>
  );
};
