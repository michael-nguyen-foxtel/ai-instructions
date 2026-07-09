# Logic Prototype

Build a tiny interactive terminal app that exercises the state machine or logic being questioned.

## Shape

- A single-file script (Node.js preferred for this stack) with a REPL or menu-driven CLI
- Each action transitions the state and prints the full state afterwards
- Cover the edge cases that are hard to reason about on paper
- Include a "show state" command that dumps the current model

## Example

```javascript
// prototype-order-state.mjs
import * as readline from 'readline/promises';

let state = { status: 'draft', items: [], total: 0 };

const actions = {
  'add': () => { /* transition logic */ },
  'submit': () => { /* transition logic */ },
  'cancel': () => { /* transition logic */ },
  'state': () => console.log(JSON.stringify(state, null, 2)),
};

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
while (true) {
  const cmd = await rl.question(`[${state.status}] > `);
  if (cmd === 'quit') break;
  actions[cmd]?.() ?? console.log('Unknown:', cmd);
}
```

Run with: `node prototype-order-state.mjs`
