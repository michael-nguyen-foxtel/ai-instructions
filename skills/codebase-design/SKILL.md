---
name: codebase-design
description: Shared vocabulary for designing deep modules. Use when designing or improving a module's interface, finding deepening opportunities, deciding where a seam goes, or making code more testable.
---

# Codebase Design

Design **deep modules**: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface.

## Glossary

Use these terms consistently:

- **Module** — anything with an interface and an implementation. Scale-agnostic: a function, class, package, or cross-repo slice.
- **Interface** — everything a caller must know: type signature, invariants, error modes, ordering constraints, performance characteristics.
- **Depth** — leverage at the interface: behaviour a caller can exercise per unit of interface they must learn. Deep = lots of behaviour behind a small interface. Shallow = interface is nearly as complex as the implementation.
- **Seam** — a place where you can alter behaviour without editing in that place. Where a module's interface lives.
- **Adapter** — a concrete thing that satisfies an interface at a seam. Describes role, not substance.

## Principles

- **Depth is a property of the interface, not the implementation.** A deep module can be internally composed of small parts — they just aren't exposed.
- **The deletion test.** If you delete the module and complexity reappears across N callers, it was earning its keep. If complexity vanishes, it was pass-through.
- **The interface is the test surface.** Callers and tests cross the same seam. If you need to test past the interface, the module is the wrong shape.
- **One adapter = hypothetical seam. Two adapters = real seam.** Don't introduce abstractions until something actually varies.

## When Designing

Ask:
1. Can I reduce the number of methods/exports?
2. Can I simplify the parameters?
3. Can I hide more complexity inside?
4. Would a caller need to know implementation details to use this correctly? (If yes, the interface is leaking.)

## Testability Guidelines

1. **Accept dependencies, don't create them** — pass collaborators in
2. **Return results, don't produce side effects** — prefer pure transforms
3. **Small surface area** — fewer exports = fewer tests needed

## When to Apply

This skill applies when:
- Creating a new module, component, or utility
- Refactoring existing code that has grown complex
- Reviewing code and noticing pass-through layers or leaky abstractions
- A module's tests require extensive mocking of internals (sign of wrong shape)

## Anti-Patterns

- **Shallow wrappers**: a module that just re-exports or delegates without adding value
- **Leaky interface**: callers must understand internals to use correctly
- **Premature seams**: abstractions introduced before a second adapter exists
- **God modules**: deep is good, but a module that does everything has too many responsibilities — split along natural seams
