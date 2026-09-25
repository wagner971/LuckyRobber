# UI palette: controlled color accents (0.9.61)

The interface keeps its navy foundation and assigns each accent a consistent role:

- Mint: PLAY, escape, completed objectives and confirmation.
- Gold: wallet, loot value and cash rewards.
- Orange: Final Job, full clear and van-full urgency.
- Purple: Special Job / Rush Hour.
- Pink: new and collected trophies.
- Cyan: neutral labels, controls and upgrade information.

Jobs now separates the normal mint PLAY action from the orange Final Job action and the smaller purple Special Job action. Home, the in-game HUD, Results and Upgrades follow the same palette. Level preview art retains its own lighting and colors. The world-space 3D cash reward animation retains its established green treatment.

Validation: Godot script parse; 55 Jobs checks with rendered pointer input, 36 studio UI checks including narrow safe areas, 19 Upgrades checks, 75 gameplay HUD checks and Home checks. Home, Jobs normal, Final Job and Special Job captures were visually inspected at portrait size.
