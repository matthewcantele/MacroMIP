# MacroMIP

Stylized shock experiment scripts and results for the MacroMIP protocol, implemented across four GTAP model variants using the [`teems`](https://teemsphere.github.io/) R package.

## Models

| Directory | Model | Solver | Notes |
|---|---|---|---|
| `R/GTAPv6` | [GTAPv6.2](https://github.com/teemsphere/teems-models) | LU | Static, classic format |
| `R/GTAPv7` | [GTAPv7.0](https://github.com/teemsphere/teems-models) | LU | Static, standard format |
| `R/GTAP-INT` | [GTAP-INTv1](https://github.com/teemsphere/teems-models) | SBBD | Intertemporal, GTAPv6 format |
| `R/GTAP-RE` | [GTAP-REv1](https://github.com/teemsphere/teems-models) | SBBD | Rational expectations; run as both `rational expectations` (default) and `adaptive recursive` (`REDELTA = 0`) |

All intertemporal runs use timesteps 2017–2050 with GTAP 11c data (reference year 2017). Static runs use no timesteps.

## Experiment protocol

Each scenario is run at a standard forcing (hash `0`) plus variants:

| Scenario | Forcing | Model(s) | Shock variable |
|---|---|---|---|
| `1-p` | Persistent −4% labour productivity, Spain (agri+construction; ¼ elsewhere) | GTAP-INT, GTAP-RE | `afeall` |
| `1-t` | Temporary (2018) equivalent of above | GTAPv6, GTAPv7, GTAP-INT, GTAP-RE | `afeall` |
| `1-o2-p` | Persistent −1% country-level labour supply, Spain | GTAP-INT, GTAP-RE | `qo` / `qe` |
| `1-o2-t` | Temporary (2018) equivalent of above | GTAPv6, GTAPv7, GTAP-INT, GTAP-RE | `qo` / `qe` |
| `2-p` | Persistent +4% increase in agriculture output, France | GTAP-INT, GTAP-RE | `aoall` |
| `2-t` | Temporary (2018) equivalent of above | GTAPv6, GTAPv7, GTAP-INT, GTAP-RE | `aoall` |
| `3-p` | Persistent −5% capital productivity in manufacturing, Germany | GTAP-INT, GTAP-RE | `afeall` |
| `3-t` | Temporary (2018) equivalent of above | GTAPv6, GTAPv7, GTAP-INT, GTAP-RE | `afeall` |

## Mappings

| File | Description |
|---|---|
| `euWB7.csv` | WB7 aggregation with EU countries resolved individually |
| `agri_cns.csv` | Sector mapping isolating agriculture and construction |
| `agriculture.csv` | Sector mapping isolating agriculture |
| `manufacturing.csv` | Sector mapping isolating manufacturing |
| `labor_diff.csv` | Endowment mapping with differentiated labour (`sklab`, `unsklab`) |

## Results

Completed runs uploaded in the format `results/<model>/<scenario>-<sfid>-<hash>/`. Each run directory contains `results.RDS` (`teems` output) and `model_diagnostics.txt`.

## Dependencies

- [`teems`](https://teemsphere.github.io/) R package — see the [manual](https://teemsphere.github.io/) for installation, data loading, and solver setup
- GTAP 11c database
- [teems-solver](https://github.com/teemsphere/teems-solver) Docker image
