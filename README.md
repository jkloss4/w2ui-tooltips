# W2UI Tooltips

A small companion addon for **W2UI** (by aesketch) that gives Blizzard's tooltips W2UI's
styled border **everywhere**, not just while they're shown over W2UI's own windows.

Retail only (Interface 120100). Requires W2UI; works alongside TipTac.

## What it does

- Applies W2UI's own tooltip styling (`W2UI.Theme:StyleEquipmentMenuFrame`) to the main tooltip, the item comparison
  tooltips, and the chat item-link tooltip and its comparison tooltips, so the look matches W2UI exactly and follows
  any changes W2UI makes to it.
- Keeps Blizzard's default border hidden whenever Blizzard, or W2UI's own restyling, tries to show it again.
- Spaces the comparison tooltips apart by the width of W2UI's border (after both Blizzard's and TipTac's anchoring),
  so neighbouring borders don't overlap.
- Moves the unit health bar below W2UI's border so it doesn't overlap it.

Trade-off: Blizzard's coloured tooltip borders (e.g. by item quality) aren't shown, as on W2UI's own windows.

No options or slash commands. If W2UI is disabled, the game won't load this addon and tooltips stay Blizzard-styled.

## Install

Download `W2UITooltips-<version>.zip` from the [latest release](../../releases/latest) and extract the
`W2UITooltips` folder into `World of Warcraft\_retail_\Interface\AddOns\`.

An addon manager that installs from GitHub releases (e.g. WowUp: *Install from URL* with this repo's URL) can also
install and update it, **but only if the repository is public**.

To update from the command line (works for a private repo, needs `gh auth login` once):

```powershell
.\scripts\update-from-release.ps1
```

## Developing / releasing

- Test local changes: `.\scripts\install-local.ps1` copies the addon folder into `AddOns`, then `/reload`.
- After a WoW patch: bump `## Interface:` in `W2UITooltips/W2UITooltips.toc`.
- Tunables are at the top of their sections in `W2UITooltips.lua`: `COMPARISON_GAP` (comparison tooltip spacing)
  and `HEALTH_BAR_OFFSET_Y` (health bar position).
- Release: `git tag v1.0.1 && git push --tags`. The [Release workflow](.github/workflows/release.yml) stamps the
  version into the TOC, builds the zip (with a `release.json` so addon managers see it's a retail build), and
  publishes the GitHub release.

## License

MIT ([`LICENSE`](LICENSE), also included in the addon folder). The border artwork comes from W2UI at runtime; none
of W2UI's files are included here.
