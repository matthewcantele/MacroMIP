# MacroMIP

Stylized shock experiment scripts and results for the MacroMIP s1 protocol (v1-2, 17.03.2026), implemented across three GTAP model variants using the [`teems`](https://teemsphere.github.io/) R package.

## Models

| Directory | Model | Solver | Notes |
|---|---|---|---|
| `R/GTAPv6` | GTAPv6.2, shipped with `teems` | LU | Static, classic format |
| `R/GTAPv7` | GTAPv7.1, shipped with `teems` | LU | Static, standard format |
| `R/GTAP-RE` | GTAP-REv2 (GTAPv7.1 core), shipped with `teems` | SBBD | Rational expectations; run as both `rational` (default) and adaptive `recursive` (`REDELTA = 0`) |

All intertemporal runs use GTAP 11c data (reference year 2017) with timesteps 2017, 2018, 2020–2030 (biennial), 2035–2050 (5-yearly) and 2060–2100 (decadal). Static runs use no timesteps.

## Aggregations

All models and scenarios share one regional and one sectoral aggregation. Endowments are `capital`, `land`, `natlres`, `sklab` and `unsklab` (`labor_diff.csv`).

### Regions

`euPartners.csv`, 48 regions from the 160 GTAP 11c regions: EU28, Norway and Switzerland at country level (protocol 3.2); the main extra-EU trade partners at country level; the rest of the world in six World Bank regions.

| Group | Regions |
|---|---|
| EU28 (28) | `aut` `bel` `bgr` `cyp` `cze` `deu` `dnk` `esp` `est` `fin` `fra` `gbr` `grc` `hrv` `hun` `irl` `ita` `ltu` `lux` `lva` `mlt` `nld` `pol` `prt` `rou` `svk` `svn` `swe` |
| Other Europe (2) | `che` `nor` |
| Extra-EU partners (12) | `aus` `bra` `can` `chn` `ind` `jpn` `kor` `mex` `rus` `sau` `tur` `usa` |
| `eap` East Asia & Pacific (16) | `brn` `hkg` `idn` `khm` `lao` `mng` `mys` `nzl` `phl` `sgp` `tha` `twn` `vnm` `xea` `xoc` `xse` |
| `eca` Europe & Central Asia (15) | `alb` `arm` `aze` `blr` `geo` `kaz` `kgz` `srb` `tjk` `ukr` `uzb` `xee` `xef` `xer` `xsu` |
| `lac` Latin America & Caribbean (25) | `arg` `bol` `chl` `col` `cri` `dom` `ecu` `gtm` `hnd` `hti` `jam` `nic` `pan` `per` `pri` `pry` `slv` `tto` `ury` `ven` `xca` `xcb` `xna` `xsm` `xtw` |
| `mena` Middle East & North Africa (18) | `are` `bhr` `dza` `egy` `irn` `irq` `isr` `jor` `kwt` `lbn` `mar` `omn` `pse` `qat` `syr` `tun` `xnf` `xws` |
| `sas` South Asia (6) | `afg` `bgd` `lka` `npl` `pak` `xsa` |
| `ssa` Sub-Saharan Africa (38) | `ben` `bfa` `bwa` `caf` `civ` `cmr` `cod` `cog` `com` `eth` `gab` `gha` `gin` `gnq` `ken` `mdg` `mli` `moz` `mus` `mwi` `nam` `ner` `nga` `rwa` `sdn` `sen` `swz` `tcd` `tgo` `tza` `uga` `xac` `xec` `xsc` `xwf` `zaf` `zmb` `zwe` |

Rest of North America (`xna`) is in `lac`.

### Sectors

`manufacturing.csv`, 27 sectors from the 65 GTAP 11c sectors, used for every scenario so that the broad sectors are composed identically across the pairs. The manufacturing sectors and construction are at GTAP resolution; the rest is aggregated.

| Sector | GTAP sectors |
|---|---|
| `crops` | `c_b` `gro` `ocr` `osd` `pdr` `pfb` `v_f` `wht` |
| `livestock` | `ctl` `oap` `rmk` `wol` |
| `frsfsh` | `frs` `fsh` |
| `mining` | `coa` `gas` `oil` `oxt` |
| `food` | `b_t` `cmt` `mil` `ofd` `omt` `pcr` `sgr` `vol` |
| manufacturing (19, unaggregated) | `bph` `chm` `eeq` `ele` `fmp` `i_s` `lea` `lum` `mvh` `nfm` `nmm` `ome` `omf` `otn` `p_c` `ppp` `rpp` `tex` `wap` |
| `util` | `ely` `gdt` |
| `cns` | `cns` |
| `svces` | `afs` `atp` `cmn` `dwe` `edu` `hht` `ins` `obs` `ofi` `osg` `otp` `ros` `rsa` `trd` `whs` `wtp` `wtr` |

Pairs 1 and 2 were first run on smaller sector sets (`agri_cns.csv`, 14 sectors; `agriculture.csv`, 13 sectors) that kept the eight crops separate but put mining and utilities inside one manufacturing aggregate and, in pair 2, construction inside services. They were rerun on the 27-sector set; the eight crops take the same shock, so the shocked set is unchanged.

## Experiment protocol

Each scenario is run at the primary forcing (hash `0`) plus the optional values of protocol Tables 2.1 and 2.2. Scenario definitions live in one place, `R/common.R` (`SCENARIOS`), and every model builds its shocks from them.

| Scenario | Forcing | Model(s) | Shock variable |
|---|---|---|---|
| `1-p` | Persistent −4% [−1, −2, −6, −8, −10] labour productivity in Spain, agriculture and construction; ¼ of it in all other sectors | GTAP-RE | `afeall` |
| `1-t` | Temporary (2018) −4% [−1, −2, −6, −8, −10] in agriculture and construction; −1% [0, −2, −3, −4, −5] in all other sectors | GTAPv6, GTAPv7, GTAP-RE | `afeall` |
| `1-o2-p` | Persistent −1% [−0.25, −0.5, −1.5, −2, −2.5] country-level labour supply, Spain | GTAP-RE | `qo` / `qe` |
| `1-o2-t` | Temporary (2018) equivalent of above | GTAPv6, GTAPv7, GTAP-RE | `qo` / `qe` |
| `2-p` | Persistent +4% [−40, −20, +20, +40] agricultural productivity, France | GTAP-RE | `aoall` |
| `2-t` | Temporary (2018) equivalent of above | GTAPv6, GTAPv7, GTAP-RE | `aoall` |
| `3-p` | Persistent −5% [−1, −2.5, −7.5, −10] capital productivity in manufacturing, Germany | GTAP-RE | `afeall` |
| `3-t` | Temporary (2018) equivalent of above | GTAPv6, GTAPv7, GTAP-RE | `afeall` |

Sector definitions:

- **Agriculture**: `crops` and `livestock`, "all crops and farming types" (protocol 2.2.1). Forestry and fishing are not included.
- **Manufacturing**: NACE C, i.e. processed food and the GTAP manufacturing sectors (`tex` to `omf`). Mining, utilities, construction and forestry are not shocked.
- Capital goods (`cgds`, GTAPv6 format) are never shocked.

Sensitivity runs: the primary runs of `1-p`, `1-t`, `2-p` and `2-t` are repeated with livestock treated as non-agriculture (pair 1: the "other sectors" shock; pair 2: unshocked), as in earlier runs. Their directories carry the suffix `-lvsnonag` (e.g. `1-p-sq-0-lvsnonag`).

## Solving

- Intertemporal models: SBBD. Gragg 2-4-6 for shocks up to 10%; adaptive DoPri54 via `ems_RK()` above that (the ±20/±40 agricultural productivity shocks). On GTAP-RE `2-p` +40 (on the earlier 13-sector set) DoPri54 matched Gragg over 4 subintervals (median relative difference 1e-5, 100% of levels to 4 figures) in a third of the time; on small shocks Gragg over one subinterval is faster.
- Static models: LU, Gragg 2-4-6, with subintervals for shocks above 10%.
- A Gragg run below 80% accuracy (results to 4 significant figures) is repeated with twice the subintervals, up to 8.

## Running

From the project root:

```sh
Rscript R/GTAP-RE/1-p-sq.R                # one model x scenario
Rscript R/run_all.R                       # everything (144 jobs)
Rscript R/run_all.R GTAP-RE 3-p 3-t       # filter by model and/or scenario
Rscript R/run_all.R --dry-run             # list the jobs
```

Jobs run in parallel as forked processes, each with its own solver container. Resources are set by environment variables:

| Variable | Default | Meaning |
|---|---|---|
| `MACROMIP_WORKERS` | 8 | concurrent jobs |
| `MACROMIP_TASKS` | 2 | MPI tasks per intertemporal job |
| `MACROMIP_THREADS` | 2 | OpenMP threads per task (static jobs: LU on tasks × threads threads) |
| `MACROMIP_OVERWRITE` | 0 | `1` reruns jobs whose results exist |

Existing results are skipped, so an interrupted batch resumes where it stopped. Each batch writes `results/run_log_<timestamp>.csv` with the status, solution method, accuracy and minutes of every job; the solver log of a job is in `runs/<model>/<run>/model_diagnostics.txt` and its R log in `macromip.log` alongside.

## Mappings

| File | Description |
|---|---|
| `euPartners.csv` | EU28, Norway, Switzerland and the main extra-EU trade partners resolved individually, WB7 for the rest (generated by `eu_partners_mapping.R`) |
| `euWB7.csv` | Earlier 37-region aggregation: WB7 with EU28, Norway and Switzerland resolved individually (generated by `eu_WB7_mapping.R`) |
| `manufacturing.csv` | Sector mapping for all scenarios: the NACE C manufacturing sectors and construction resolved individually |
| `agri_cns.csv` | Earlier 14-sector mapping for pair 1, isolating the crops, livestock and construction |
| `agriculture.csv` | Earlier 13-sector mapping for pair 2, isolating the crops and livestock |
| `labor_diff.csv` | Endowment mapping with differentiated labour (`sklab`, `unsklab`) |

## Results

Completed runs are written as `results/<model>/<scenario>-<sfid>-<hash>/`. Each run directory contains `results.RDS` (`teems` output) and `model_diagnostics.txt`.

## Dependencies

- [`teems`](https://teemsphere.github.io/) R package ≥ 1.0.1 (CRAN): `install.packages("teems")`
- [teems-solver](https://github.com/teemsphere/teems-solver) Docker image ≥ 1.1.0, tagged `teems:latest`
- GTAP 11c database, located through the environment variables `GTAP11c_dat`, `GTAP11c_par` and `GTAP11c_set` (e.g. in `~/.Renviron`)
