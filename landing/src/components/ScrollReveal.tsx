import { useScrollReveal } from '../hooks/useScrollReveal';
import type { ReactNode } from 'react';

interface ScrollRevealProps {
  children: ReactNode;
  delay?: 0 | 1 | 2 | 3 | 4;
  className?: string;
}

export function ScrollReveal({ children, delay = 0, className = '' }: ScrollRevealProps) {
  const { ref, isVisible } = useScrollReveal();

  const delayClass = delay > 0 ? `scroll-reveal-delay-${delay}` : '';
  const visibleClass = isVisible ? 'is-visible' : '';

  return (
    <div ref={ref} className={`scroll-reveal ${delayClass} ${visibleClass} ${className}`.trim()}>
      {children}
    </div>
  );
}
