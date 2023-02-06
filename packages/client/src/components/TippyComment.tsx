import { ReactElement } from 'react'
import Tippy from '@tippyjs/react/headless'
import 'tippy.js/animations/perspective.css';

export default function TippyComment({children, content}: { children: ReactElement, content: ReactElement|string }) {
  return <Tippy
    offset={[0, 0]}
    animation='perspective'
    render={attrs => (
      <div className="text-dark-comment bg-dark-500 p-2 border border-dark-400"
           tabIndex={-1} {...attrs}>
        {content}
      </div>
    )}
  >
    {children}
  </Tippy>
}