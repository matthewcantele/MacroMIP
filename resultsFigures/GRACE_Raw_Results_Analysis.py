#!/usr/bin/env python
# coding: utf-8

# Benjamin Blanz
# 2024

# ipython command do reset the environment.
# not valid basic python syntax so tell pyflake to ignore the line with noqa
# %reset -f # flake8: noqa

#%% librarys
print('loading libs')

import numpy as np
import pandas as pd
import geopandas as gpd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import matplotlib.colors as mcolors
import matplotlib.patches as patches
import matplotlib.patheffects as path_effects
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
import os

#%% config

# show the plots?
showPlots = False

thing = 'real_output_mean'
sector_thing = 'real_sector_output_mean_nace1'
cmap_rel = cm.coolwarm_r
cmap_abs = cm.BuPu



#%% Constants data labels
# List of country codes
country_codes = ['AT', 'BE', 'BG', 'CY', 'CZ', 'DE', 'DK', 'EE', 'EL', 'ES', 'FI', 'FR', 'HR',
                 'HU', 'IE', 'IT', 'LT', 'LU', 'LV', 'NL', 'PL', 'PT', 'RO', 'SE', 'SI', 'SK']
country_codes_3 = ['AUT', 'BEL', 'BGR', 'CYP', 'CZE', 'DEU', 'DNK', 'EST', 'GRC', 'ESP', 'FIN', 'FRA', 'HRV',
                 'HUN', 'IRL', 'ITA', 'LTU', 'LUX', 'LVA', 'NLD', 'POL', 'PRT', 'ROU', 'SWE', 'SVN', 'SVK']
regions=['AT11', 'AT12', 'AT13', 'AT21', 'AT22', 'AT31', 'AT32', 'AT33', 'AT34', 'BE10', 'BE21', 'BE22', 'BE23',
         'BE24', 'BE25', 'BE31', 'BE32', 'BE33', 'BE34', 'BE35', 'BG31', 'BG32', 'BG33', 'BG34', 'BG41', 'BG42',
         'CY00', 'CZ01', 'CZ02', 'CZ03', 'CZ04', 'CZ05', 'CZ06', 'CZ07', 'CZ08', 'DE11', 'DE12', 'DE13', 'DE14',
         'DE21', 'DE22', 'DE23', 'DE24', 'DE25', 'DE26', 'DE27', 'DE30', 'DE40', 'DE50', 'DE60', 'DE71', 'DE72',
         'DE73', 'DE80', 'DE91', 'DE92', 'DE93', 'DE94', 'DEA1', 'DEA2', 'DEA3', 'DEA4', 'DEA5', 'DEB1', 'DEB2',
         'DEB3', 'DEC0', 'DED2', 'DED4', 'DED5', 'DEE0', 'DEF0', 'DEG0', 'DK01', 'DK02', 'DK03', 'DK04', 'DK05',
         'EE00', 'EL30', 'EL41', 'EL42', 'EL43', 'EL51', 'EL52', 'EL53', 'EL54', 'EL61', 'EL62', 'EL63', 'EL64',
         'EL65', 'ES11', 'ES12', 'ES13', 'ES21', 'ES22', 'ES23', 'ES24', 'ES30', 'ES41', 'ES42', 'ES43', 'ES51',
         'ES52', 'ES53', 'ES61', 'ES62', 'ES63', 'ES64', 'ES70', 'FI1B', 'FI1C', 'FI1D', 'FI19', 'FI20', 'FR10',
         'FRB0', 'FRC1', 'FRC2', 'FRD1', 'FRD2', 'FRE1', 'FRE2', 'FRF1', 'FRF2', 'FRF3', 'FRG0', 'FRH0', 'FRI1',
         'FRI2', 'FRI3', 'FRJ1', 'FRJ2', 'FRK1', 'FRK2', 'FRL0', 'FRM0', 'FRY1', 'FRY2', 'FRY3', 'FRY4', 'HR03',
         'HU11', 'HU12', 'HU21', 'HU22', 'HU23', 'HU31', 'HU32', 'HU33', 'IE04', 'IE05', 'IE06', 'ITC1', 'ITC2',
         'ITC3', 'ITC4', 'ITF1', 'ITF2', 'ITF3', 'ITF4', 'ITF5', 'ITF6', 'ITG1', 'ITG2', 'ITH1', 'ITH2', 'ITH3',
         'ITH4', 'ITH5', 'ITI1', 'ITI2', 'ITI3', 'ITI4', 'LT01', 'LT02', 'LU00', 'LV00', 'NL11', 'NL12', 'NL13',
         'NL21', 'NL22', 'NL23', 'NL31', 'NL32', 'NL33', 'NL34', 'NL41', 'NL42', 'PL21', 'PL22', 'PL41', 'PL42',
         'PL43', 'PL51', 'PL52', 'PL61', 'PL62', 'PL63', 'PL71', 'PL72', 'PL81', 'PL82', 'PL84', 'PL91', 'PL92',
         'PT11', 'PT15', 'PT16', 'PT17', 'PT18', 'PT20', 'PT30', 'RO11', 'RO12', 'RO21', 'RO22', 'RO31', 'RO32',
         'RO41', 'RO42', 'SE11', 'SE12', 'SE21', 'SE22', 'SE23', 'SE31', 'SE32', 'SE33', 'SI03', 'SI04', 'SK01',
         'SK02', 'SK03', 'SK04'];
danube_countries = ['DE', 'AT', 'CZ', 'HU', 'SK', 'SI', 'RO', 'BG', 'HR']
# List of NUTS-2 codes for the specified countries and German regions
danube_nuts_2 = [
    # Germany
    'DE11', 'DE13', 'DE14', 'DE21', 'DE22', 'DE23', 'DE24', 'DE25', 'DE26', 'DE27',
    # Austria
    'AT11', 'AT12', 'AT13', 'AT21', 'AT22', 'AT31', 'AT32', 'AT33', 'AT34',
    # Czechia
    'CZ01', 'CZ02', 'CZ03', 'CZ04', 'CZ05', 'CZ06', 'CZ07', 'CZ08',
    # Hungary
    'HU11', 'HU12', 'HU21', 'HU22', 'HU23', 'HU31', 'HU32', 'HU33',
    # Slovenia
    'SI03', 'SI04',
    # Croatia
    'HR03', #'HR04',
    # Romania
    'RO11', 'RO12', 'RO21', 'RO22', 'RO31', 'RO32', 'RO41', 'RO42',
    # Bulgaria
    'BG31', 'BG32', 'BG33', 'BG34', 'BG41', 'BG42'
]
sectors_nace_62 = ['A01', 'A02', 'A03', 'B', 'C10-C12', 'C13-C15', 'C16', 'C17', 'C18', 'C19', 'C20', 'C21', 'C22', 'C23',
           'C24', 'C25', 'C26', 'C27', 'C28', 'C29', 'C30', 'C31_C32', 'C33', 'D', 'E36', 'E37-E39', 'F', 'G45',
           'G46', 'G47', 'H49', 'H50', 'H51', 'H52', 'H53', 'I', 'J58', 'J59_J60', 'J61', 'J62_J63', 'K64', 'K65',
           'K66', 'L', 'M69_M70', 'M71', 'M72', 'M73', 'M74_M75', 'N77', 'N78', 'N79', 'N80-N82', 'O', 'P',
           'Q86', 'Q87_Q88', 'R90-R92', 'R93', 'S94', 'S95', 'S96']
sectors_nace_1 = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S']
key_sectors = ['A01', 'H50', 'H51', 'H52', 'H53', 'K64', 'K65']

time_steps = [f"Quarter {i}" for i in range(0,13)]

experiments = [f"E{i}" for i in range(0,18)]

dimensionLabels = {"countries":country_codes,"sectors_nace_62":sectors_nace_62,"sectors_nace_1":sectors_nace_1,"time":time_steps,"experiments":experiments}
dimensionLabelsLengths =  [len(dimensionLabels[i]) for i in dimensionLabels.keys()]

sectors_nace_1_colors =  cm.tab20.colors
sectors_nace_62_colors =  cm.tab20(np.linspace(0, 1, len(sectors_nace_62)))

#%% sector aggregation function
def aggregateSectorNace62ToNace1(inArray):
    shape = list(inArray.shape)
    sectorDim = shape.index(len(sectors_nace_62))
    shape[sectorDim] = len(sectors_nace_1)
    aggArray = np.ones(shape)
    for t in range(len(time_steps)):
        for c in range(len(country_codes)):
            for s in range(len(sectors_nace_1)):
                matched_sector_idcs = [sectors_nace_62.index(sector) for sector in sectors_nace_62 if sector.startswith(sectors_nace_1[s])]
                if len(shape)==4:
                    for e in range(len(experiments)):
                        aggArray[t,e,c,s] = sum(inArray[t,e,c,matched_sector_idcs])
                else:
                    aggArray[t,c,s] = sum(inArray[t,c,matched_sector_idcs])
    return aggArray

#%% load data
print('loading data')
# `data` is a dictionary with variable names as keys and loaded matrices as values
shock_eq_in = pd.read_excel('data/GRACE/OutputImpacts_scenarios.xlsx','earthquake_mean')
shock_eq = {}
shock_eq['real_sector_output_mean_nace1']=np.array(shock_eq_in[['country']+sectors_nace_1])
shock_eq['real_output_mean']=np.array(shock_eq_in[['country']+['Total']])
shock_f_in = pd.read_excel('data/GRACE/OutputImpacts_scenarios.xlsx','flood2010')
shock_f = {}
shock_f['real_sector_output_mean_nace1']=np.array(shock_f_in[['country']+sectors_nace_1])
shock_f['real_output_mean']=np.array(shock_f_in[['country']+['Total']])


scenarios_dif_rel = [shock_f, shock_eq]
scenarios_names = ["flood", "earthquake"]
scenarios_colors = ["deepskyblue", "indianred"]
scenarios_linest = ["-","-"]

#%% load and prepare map shape
print('loading map')

sns.set(style="whitegrid", palette="pastel", color_codes=True)
sns.mpl.rc("figure", figsize=(10,6))
world = gpd.read_file("data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp")
europe = world#world[world['CONTINENT']=='Europe']
europe.insert(len(europe.columns), 'INSET_FIG_X', europe['LABEL_X'])
europe.insert(len(europe.columns), 'INSET_FIG_Y', europe['LABEL_Y'])

europe.loc[europe['ADM0_A3']=='LUX','INSET_FIG_X'] = 2
europe.loc[europe['ADM0_A3']=='LUX','INSET_FIG_Y'] = 54

europe.loc[europe['ADM0_A3']=='NLD','INSET_FIG_X'] = 5.8
europe.loc[europe['ADM0_A3']=='NLD','INSET_FIG_Y'] = 53

europe.loc[europe['ADM0_A3']=='BEL','INSET_FIG_X'] = 2.4
europe.loc[europe['ADM0_A3']=='BEL','INSET_FIG_Y'] = 56

europe.loc[europe['ADM0_A3']=='HRV','INSET_FIG_X'] = 16.9
europe.loc[europe['ADM0_A3']=='HRV','INSET_FIG_Y'] = 43.7

europe.loc[europe['ADM0_A3']=='AUT','INSET_FIG_X'] = 12.3
europe.loc[europe['ADM0_A3']=='AUT','INSET_FIG_Y'] = 47.5

europe.loc[europe['ADM0_A3']=='ITA','INSET_FIG_X'] = 12
europe.loc[europe['ADM0_A3']=='ITA','INSET_FIG_Y'] = 43.3

europe.loc[europe['ADM0_A3']=='LVA','INSET_FIG_X'] = 21
europe.loc[europe['ADM0_A3']=='LVA','INSET_FIG_Y'] = 58.2

europe.loc[europe['ADM0_A3']=='LUX','INSET_FIG_X'] = 0.2
europe.loc[europe['ADM0_A3']=='LUX','INSET_FIG_Y'] = 52.5

europe.loc[europe['ADM0_A3']=='HUN','INSET_FIG_X'] = 19.6
europe.loc[europe['ADM0_A3']=='HUN','INSET_FIG_Y'] = 47.5

europe.loc[europe['ADM0_A3']=='ROU','INSET_FIG_X'] = 24.2
europe.loc[europe['ADM0_A3']=='ROU','INSET_FIG_Y'] = 46.5

europe.loc[europe['ADM0_A3']=='BGR','INSET_FIG_X'] = 25.5
europe.loc[europe['ADM0_A3']=='BGR','INSET_FIG_Y'] = 42.1

europe.loc[europe['ADM0_A3']=='SVN','INSET_FIG_X'] = 5
europe.loc[europe['ADM0_A3']=='SVN','INSET_FIG_Y'] = 40

europe.loc[europe['ADM0_A3']=='SVK','INSET_FIG_X'] = 26
europe.loc[europe['ADM0_A3']=='SVK','INSET_FIG_Y'] = 50.5

europe.loc[europe['ADM0_A3']=='EST','INSET_FIG_X'] = 25.9
europe.loc[europe['ADM0_A3']=='EST','INSET_FIG_Y'] = 59

europe.loc[europe['ADM0_A3']=='CZE','INSET_FIG_X'] = 15.8
europe.loc[europe['ADM0_A3']=='CZE','INSET_FIG_Y'] = 49.88

europe.loc[europe['ADM0_A3']=='POL','INSET_FIG_X'] = 19.6
europe.loc[europe['ADM0_A3']=='POL','INSET_FIG_Y'] = 52

europe.loc[europe['ADM0_A3']=='SWE','INSET_FIG_X'] = 15
europe.loc[europe['ADM0_A3']=='SWE','INSET_FIG_Y'] = 62

#%% iterate over entries of data and print out shape
# print('Basic shape of Data')
# describeData(base)

#%% histogram of impacts
scenariosToPlot = [0,1]

plotType = 'dif_rel'

for scenario_index in scenariosToPlot:
    thing_df = pd.DataFrame(scenarios_dif_rel[scenario_index][thing])
    plt.hist(thing_df[1])

#%% spatial plot
print('plotting maps')
basefigdir = 'figures/GRACE/maps'

subfig_size = (15,15)
nrows=1
ncols=1
max_val = 0
min_val = 0
for s in range(len(scenarios_dif_rel)):
    max_val = max(max_val,np.max(scenarios_dif_rel[s][thing][:,1]))
    min_val = min(min_val,np.min(scenarios_dif_rel[s][thing][:,1]))
max_val = max(abs(min_val),abs(max_val))
min_val = -max_val

scenariosToPlot = [0,1]

plotType = 'dif_rel'

for scenario_index in scenariosToPlot:
    if os.path.isfile(basefigdir + '/map-'+ thing + '_in_' + scenarios_names[scenario_index] + '_scenario_as_' + plotType + '.png'):
        print('skipping spatial plots for scenario ' + scenarios_names[scenario_index] + ' file exists.')
    else:
        print('plotting spatial plots for scenario ' + scenarios_names[scenario_index])
        thing_df = pd.DataFrame(scenarios_dif_rel[scenario_index][thing])

        # initialize the figure
        fig, axes = plt.subplots(1, 1, figsize=(subfig_size[0]*ncols,subfig_size[1]*nrows ))
        ax = axes
        fig.suptitle(thing + ' in ' + scenarios_names[scenario_index] + ' scenario as ' + plotType)
        row = 0
        col = 0

        mergedData = europe.merge(thing_df, how='left', left_on=europe['ADM0_A3'].str.lower(), right_on=thing_df['country'].str.lower())

        # for testing
        # fig, axes =plt.subplots(1,1, figsize=(subfig_size[0]*ncols,subfig_size[1]*nrows ))
        # ax = axes

        # define colors
        if plotType == 'abs':
            # stop('not applicable')
            cmap = cmap_abs
            min_val, max_val = min(thing_df[thing]), max(thing_df[thing])
        if plotType == 'dif_rel':
            cmap = cmap_rel
        norm = mcolors.Normalize(vmin=min_val, vmax=max_val)

        # create the plot
        mergedData.plot(column='Total', cmap=cmap, norm=norm,
                        edgecolor='black', linewidth=0.2,ax=ax)

        # custom axis
        ax.set_xlim(-15, 35)
        ax.set_ylim(32, 72)
        ax.axis('off')


        # color legend
        ax_lgd = inset_axes(ax,width=subfig_size[0]*0.02,height=subfig_size[1]*0.2,loc='right')
        norm.lgd = mcolors.Normalize(vmin=min_val*100, vmax=max_val*100)
        sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm.lgd)
        plt.colorbar(sm,cax=ax_lgd,location='left',shrink=0.01,
                     label='change relative to baseline',
                     format="%+.0f %%")

        # title
        # ax.title.set_text('Change in real output compared to baseline ' + scenarios_names[scenario_index] +' scenario')

        # for testing
        # plt.show()

        # save just the subplot
        figdir = basefigdir + '/' + scenarios_names[scenario_index]
        if not os.path.exists(figdir):
            os.makedirs(figdir)
        fig.savefig(figdir+'/map-'+ sector_thing + '_in_' + scenarios_names[scenario_index] +
                    '_scenario_as_' + plotType + '.png',
                    dpi=300,
                    bbox_inches=ax.get_window_extent().transformed(fig.dpi_scale_trans.inverted()).expanded(1.04, 1.06))
        fig.savefig(figdir+'/map-'+ sector_thing + '_in_' + scenarios_names[scenario_index] +
                    '_scenario_as_' + plotType + '.pdf',
                    bbox_inches=ax.get_window_extent().transformed(fig.dpi_scale_trans.inverted()).expanded(1.04, 1.06))

        # Hide unused subplots
        for index in range(len(time_steps), nrows*ncols):  # Adjust the range if the grid size is changed
            if(col==ncols):
                row+=1
                col=0
            axes[row, col].axis('off')
            col+=1

        # display the plot
        plt.tight_layout()
        if showPlots: plt.show()

        figdir = basefigdir
        if not os.path.exists(figdir):
            os.makedirs(figdir)
        fig.savefig(figdir + '/map-'+ thing + '_in_' + scenarios_names[scenario_index] + '_scenario_as_' + plotType + '.png',
                                dpi=300)
        fig.savefig(figdir + '/map-'+ thing + '_in_' + scenarios_names[scenario_index] + '_scenario_as_' + plotType + '.pdf')

        plt.close(fig)

#%% pie chart config
plotType = 'dif_rel'
country_index = 22
scenario_index = 1
base_radius = 0.5
nrows=3
ncols=6
subfig_size=[3,3]

wedgeprops={"edgecolor":"k","linewidth":0.5}

sector_colors= sectors_nace_1_colors
sector_names = sectors_nace_1

max_val = 0
min_val = 0
for s in range(len(scenarios_dif_rel)):
    max_val = max(max_val,np.max(scenarios_dif_rel[s][thing][:,1]))
    min_val = min(min_val,np.min(scenarios_dif_rel[s][thing][:,1]))
max_val = max(abs(min_val),abs(max_val))
min_val = -max_val

max_sectorThing_val = 0
min_sectorThing_val = 0
for s in range(len(scenarios_dif_rel)):
    max_sectorThing_val = max(max_sectorThing_val,np.max(scenarios_dif_rel[s][sector_thing][:,range(1,1+len(sectors_nace_1))]))
    min_sectorThing_val = min(min_sectorThing_val,np.min(scenarios_dif_rel[s][sector_thing][:,range(1,1+len(sectors_nace_1))]))

rel_change_scaling = 5

#circle scale lines
sclLin_sty = ['--',':','-',':']
sclLin_wth = [1,1,0.1,1]
sclLin_rad = [-0.01,0,0.01]
sclLin_lab = ['-5%','-1%','ref','+1%']
sclLin_col = ['k','k','k','k']



#%% function pie charts real output per sector

def addRelChangePiePlot(piedata,ax):
    country_index_GRACE_output=int(np.where(scenarios_dif_rel[scenario_index][sector_thing][:,0]==country_codes_3[country_index].lower())[0][0])
    #circle scale lines
    ax.add_patch(plt.Circle((0,0), base_radius*(1-0.1*rel_change_scaling), linestyle='--',
                            fill = False, edgecolor='gray', linewidth=1))
    ax.add_patch(plt.Circle((0,0), base_radius*(1-0.05*rel_change_scaling), linestyle=':',
                            fill = False, edgecolor='gray', linewidth=1))
    ax.add_patch(plt.Circle((0,0), base_radius, linestyle='-', fill = False, edgecolor='k' ))
    ax.add_patch(plt.Circle((0,0), base_radius*(1+0.05*rel_change_scaling), linestyle=':',
                            fill = False, edgecolor='gray', linewidth=1))

    # the pie wedges
    for s in range(len(piedata)):
        radius=max(0.000001,
                   base_radius + rel_change_scaling* scenarios_dif_rel[scenario_index][sector_thing][country_index_GRACE_output,s+1])
        wedges1, texts1 = ax.pie(piedata, radius=radius,
                                 colors=sector_colors, wedgeprops=wedgeprops, counterclock=False, startangle=-270)
        for wi in range(len(wedges1)):
            if wi != s:
                wedges1[wi].set_visible(False)
#%% function pie charts real output per sector only rel diff

def addBrokenDonutPlot(piedata,ax,country_index,halo=False,empty=False):
    country_index_GRACE_output=int(np.where(scenarios_dif_rel[scenario_index][sector_thing][:,0]==country_codes_3[country_index].lower())[0][0])
    shdCirc_rad = 0
    shdCirc_lwd = [3,6,8,10,12,14,16,20,22,24,26,28,30]
    for i in range(len(sclLin_rad)):
        circle = plt.Circle((0,0), base_radius*(1+sclLin_rad[i]*rel_change_scaling), linestyle=sclLin_sty[i],
                            fill = False, edgecolor=sclLin_col[i], linewidth=sclLin_wth[i])
        ax.add_patch(circle)
        if sclLin_rad[i]==shdCirc_rad and halo:
            for j in range(len(shdCirc_lwd)):
                shadowArgs = dict(alpha=0.05,antialiased = True, color='white',linewidth=shdCirc_lwd[j],linestyle='-')
                ax.add_patch(patches.Shadow(circle,0,0,shade=1,**shadowArgs))
    if empty:
        circle = plt.Circle((0,0), base_radius*(1),linestyle='-', fill = False, edgecolor='k' )
        ax.pie(piedata, radius=0.0000000000000000000001,
                                 colors=sector_colors, wedgeprops=wedgeprops, counterclock=False, startangle=-270,
                                 shadow=False)
    else:
        for s in range(len(piedata)):
            if scenarios_dif_rel[1][sector_thing][country_index,s+1] >= 0:
                wedges1, texts1 = ax.pie(piedata, radius=max(0.0000000000000000000001,base_radius * (1 + rel_change_scaling * scenarios_dif_rel[scenario_index][sector_thing][country_index_GRACE_output,s+1])),
                                         colors=sector_colors, wedgeprops=wedgeprops, counterclock=False, startangle=-270,
                                         shadow=False)
                wedges1[s].set_width(base_radius*(1-1/1 + rel_change_scaling * scenarios_dif_rel[scenario_index][sector_thing][country_index_GRACE_output,s+1]))
            else:
                wedges1, texts1 = ax.pie(piedata, radius=base_radius,
                                         colors=sector_colors, wedgeprops=wedgeprops, counterclock=False, startangle=-270,
                                         shadow=False)
                wedges1[s].set_width(- base_radius * rel_change_scaling * scenarios_dif_rel[scenario_index][sector_thing][country_index_GRACE_output,s+1])
            for wi in range(len(wedges1)):
                if wi != s:
                    wedges1[wi].set_visible(False)



#%% pie charts time slices
print('plotting pies by time')

nrows=5
ncols=6
scenariosToPlot = [1,0]
selectedCountryCodes = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25] # omitting 22 ROU as currently mmagnification is maxed

for bakedGoodType in ['brokendonuts']:#['brokendonuts','pies']:
    print('plotting '+bakedGoodType+' by time')
    basefigdir = 'figures/GRACE/'+bakedGoodType
    for scenario_index in [1]:#scenariosToPlot:
        figdir =basefigdir + '/' + scenarios_names[scenario_index]
        if False and os.path.isfile(figdir+'/' + bakedGoodType +'-'+ sector_thing + '_in_' + scenarios_names[scenario_index] + '_scenario_as_' + plotType + '.png'):
            print('skipping ' + sector_thing + ' in ' + scenarios_names[scenario_index] + ' scenario as ' + plotType +
               ' file exists.')
        else:
            print('plotting ' + sector_thing + ' in ' + scenarios_names[scenario_index] + ' scenario as ' + plotType)
            fig, axes = plt.subplots(nrows, ncols, figsize=(subfig_size[0]*ncols,subfig_size[1]*nrows ))
            fig.suptitle(sector_thing + ' in ' + scenarios_names[scenario_index] + ' scenario as ' + plotType)
            row = 0
            col = 0
            for country_index in selectedCountryCodes:
                # determine subfigure
                if(col==ncols):
                    row+=1
                    col=0
                if row>=nrows or col>=ncols:
                    break
                if ncols > 1:
                    ax = axes[row, col]
                else:
                    ax = axes[row]
                col+=1
                # for testing
                # fig, axes =plt.subplots(1,1, figsize=(subfig_size[0]*ncols,subfig_size[1]*nrows ))
                # ax = axes
                piedata = base[sector_thing][0,country_index,:]
                if bakedGoodType=='pies':
                    addRelChangePiePlot(piedata,ax)
                else:
                    addBrokenDonutPlot(piedata,ax,country_index)
                # title
                ax.title.set_text(country_codes[country_index])
            # Hide unused subplots
            for country_index in range(len(country_codes), nrows*ncols-2):
                if(col==ncols):
                    row+=1
                    col=0
                axes[row, col].axis('off')
                col+=1

            # scale lines legend
            ax = axes[nrows-1,ncols-2]
            addBrokenDonutPlot(piedata,ax,empty=True,country_index=0)
            for i in range(len(sclLin_rad)):
                ax.text(0,base_radius*(1+sclLin_rad[i]*rel_change_scaling),sclLin_lab[i],fontsize=8,
                          backgroundcolor='white',color=sclLin_col[i],horizontalalignment='center',
                          verticalalignment='center',bbox=dict(alpha=0))

            # ax.add_patch(plt.Circle((0,0), (1-0.1*rel_change_scaling), linestyle='--', fill = False, edgecolor='gray', linewidth=1))
            # ax.add_patch(plt.Circle((0,0), (1-0.05*rel_change_scaling), linestyle=':', fill = False, edgecolor='gray', linewidth=1))
            # ax.add_patch(plt.Circle((0,0), 1, linestyle='-', fill = False, edgecolor='k' ))
            # ax.add_patch(plt.Circle((0,0), (1+0.05*rel_change_scaling), linestyle=':', fill = False, edgecolor='gray', linewidth=1))
            # ax.text(0,(1-0.1*rel_change_scaling),'-10%',fontsize=10,
            #           backgroundcolor='white',color='gray',horizontalalignment='center',verticalalignment='center')
            # ax.text(0,(1-0.05*rel_change_scaling),'-5%',fontsize=10,
            #           backgroundcolor='white',color='gray',horizontalalignment='center',verticalalignment='center')
            # ax.text(0,1,'reference',fontsize=10,
            #           backgroundcolor='white',color='black',horizontalalignment='center',verticalalignment='center')
            # ax.text(0,(1+0.05*rel_change_scaling),'+5%',fontsize=10,
            #           backgroundcolor='white',color='gray',horizontalalignment='center',verticalalignment='center')
            # ax.text(0,(1+0.1*rel_change_scaling),'+10%',fontsize=10,
            #           backgroundcolor='white',color='gray',horizontalalignment='center',verticalalignment='center')

            # sector color legends
            ax =  axes[nrows-1,ncols-1]
            wedges, texts = ax.pie(np.ones(len(piedata)),radius=base_radius, colors=sector_colors, labels=sector_names,
                                     wedgeprops=wedgeprops, counterclock=False, startangle=-270)
            ax.title.set_text('Sectors')

            # display the plot
            plt.tight_layout()
            if showPlots:
                plt.show()

            # save the plot
            if not os.path.exists(figdir):
                os.makedirs(figdir)
            fig.savefig(figdir+'/' + bakedGoodType +'-'+ sector_thing + '_in_' + scenarios_names[scenario_index] + '_scenario_as_' + plotType + '.png',
                                    dpi=300)
            fig.savefig(figdir+'/' + bakedGoodType +'-'+ sector_thing + '_in_' + scenarios_names[scenario_index] + '_scenario_as_' + plotType + '.pdf')

            plt.close(fig)



#%% spatial pie config

subfig_size = (15,15)
insetfig_size = min(subfig_size)*0.15
base_radius = 0.5

#%% spatial pie plot
print('plotting maps with broken donuts')

sns.set(style="whitegrid", palette="pastel", color_codes=True)

max_val = max(abs(min_val),abs(max_val))
min_val = -max_val

scenariosToPlot = [0,1,2,3]

for insetType in ['bars','brokendonut']:
    basefigdir='figures/GRACE/maps-' + insetType
    for scenario_index in scenariosToPlot:
        figdir = basefigdir + '/' + scenarios_names[scenario_index]
        if os.path.isfile(figdir+'/brokendonut-'+ sector_thing + '_in_' +
                          scenarios_names[scenario_index] + '_scenario_as_' +
                        plotType + '.png'):
            print('skipping ' + sector_thing + ' in ' + scenarios_names[scenario_index] + ' scenario as ' + plotType + ' file exists.')
        else:
            print('plotting ' + sector_thing + ' in ' + scenarios_names[scenario_index] + ' scenario as ' + plotType)
            print('running scenario '+scenarios_names[scenario_index])
            if plotType == 'abs':
                thing_df = pd.DataFrame({'time': np.repeat(time_steps, len(country_codes)), 'country': country_codes_3 * len(time_steps),
                                         thing:base[thing].flatten()})
            if plotType == 'dif_rel':
                thing_df = pd.DataFrame({'time': np.repeat(time_steps, len(country_codes)), 'country': country_codes_3 * len(time_steps),
                                         thing:scenarios_dif_rel[scenario_index][thing].flatten()})


            # initialize the figure
            nrows=3
            ncols=6
            fig, axes = plt.subplots(nrows, ncols, figsize=(subfig_size[0]*ncols,subfig_size[1]*nrows))
            plt.tight_layout()
            fig.suptitle(thing + ' in ' + scenarios_names[scenario_index] + ' scenario as ' + plotType)
            row = 0
            col = 0
            for time_index, timestep in enumerate(time_steps):
                print(' time step ' + timestep)
                # determine subfigure
                if(col==ncols):
                    row+=1
                    col=0
                if row>=nrows or col>=ncols:
                    break
                if ncols > 1:
                    ax = axes[row, col]
                else:
                    ax = axes[row]
                col+=1
                # define colors
                if plotType == 'abs':
                    cmap = cm.Reds
                    min_val, max_val = min(thing_df[thing]), max(thing_df[thing])
                if plotType == 'dif_rel':
                    cmap = cm.twilight_shifted_r#cm.seismic_r
                norm = mcolors.Normalize(vmin=min_val, vmax=max_val)

                # create the plot
                thing_df_1 = thing_df[thing_df['time']==timestep]
                mergedData = europe.merge(thing_df_1, how='left', left_on='ADM0_A3', right_on='country')
                mergedData.plot(column=thing, cmap=cmap, norm=norm,
                                edgecolor='black', linewidth=0.2,ax=ax)

                # custom axis
                ax.set_xlim(-10, 35)
                ax.set_ylim(32, 67)
                ax.axis('off')

                # arrow for BEL inset
                ax.add_patch(patches.FancyArrowPatch((europe['LABEL_X'][europe['ADM0_A3']=='BEL'].iloc[0],
                                                          europe['LABEL_Y'][europe['ADM0_A3']=='BEL'].iloc[0]),
                                                          (europe['INSET_FIG_X'][europe['ADM0_A3']=='BEL'].iloc[0],
                                                          europe['INSET_FIG_Y'][europe['ADM0_A3']=='BEL'].iloc[0]-1.9),
                                                          color='k', linewidth=0.2,connectionstyle="arc3,rad=-.3"))

                # arrow for LUX inset
                ax.add_patch(patches.FancyArrowPatch((europe['LABEL_X'][europe['ADM0_A3']=='LUX'].iloc[0],
                                                          europe['LABEL_Y'][europe['ADM0_A3']=='LUX'].iloc[0]),
                                                          (europe['INSET_FIG_X'][europe['ADM0_A3']=='LUX'].iloc[0]+1.3,
                                                          europe['INSET_FIG_Y'][europe['ADM0_A3']=='LUX'].iloc[0]-1.3),
                                                          color='k', linewidth=0.2,connectionstyle="arc3,rad=-.3"))

                # arrow for SVN inset
                ax.add_patch(patches.FancyArrowPatch((europe['LABEL_X'][europe['ADM0_A3']=='SVN'].iloc[0],
                                                          europe['LABEL_Y'][europe['ADM0_A3']=='SVN'].iloc[0]),
                                                          (europe['INSET_FIG_X'][europe['ADM0_A3']=='SVN'].iloc[0]+1.9,
                                                          europe['INSET_FIG_Y'][europe['ADM0_A3']=='SVN'].iloc[0]),
                                                          color='k', linewidth=0.2,connectionstyle="arc3,rad=-.6"))

                # arrow for SVK inset
                ax.add_patch(patches.FancyArrowPatch((europe['LABEL_X'][europe['ADM0_A3']=='SVK'].iloc[0]+2,
                                                          europe['LABEL_Y'][europe['ADM0_A3']=='SVK'].iloc[0]),
                                                          (europe['INSET_FIG_X'][europe['ADM0_A3']=='SVK'].iloc[0]-1.3,
                                                          europe['INSET_FIG_Y'][europe['ADM0_A3']=='SVK'].iloc[0]-1.3),
                                                          color='k', linewidth=0.2,connectionstyle="arc3,rad=.1"))
                # country inset plots
                for country_index in range(len(country_codes)):
                    print('   Making inset ' + country_codes_3[country_index])
                    ax_sub = inset_axes(ax, width=insetfig_size, height=insetfig_size, loc=10,
                                        bbox_to_anchor=(europe[europe['ADM0_A3']==country_codes_3[country_index]]['INSET_FIG_X'],
                                                        europe[europe['ADM0_A3']==country_codes_3[country_index]]['INSET_FIG_Y']),
                                        bbox_transform=ax.transData)
                    piedata = base[sector_thing][time_index,country_index,:]
                    if insetType == 'brokendonut':
                        addBrokenDonutPlot(piedata,ax_sub,halo=True)
                        text=ax_sub.text(0,0,country_codes[country_index],color='gray',ha='center',va='center',weight='bold')
                    else:
                        addRelChangeStackedBarPlot(piedata,scenarios_dif_rel[scenario_index][sector_thing][time_index,country_index,:],ax_sub)
                        text=ax_sub.text(0.3,0,country_codes[country_index],color='gray',ha='center',va='center',weight='bold')
                    text.set_path_effects([path_effects.Stroke(linewidth=3, foreground='white',alpha=0.8),
                                           path_effects.Normal()])

                # color legend
                ax_lgd = inset_axes(ax,width=subfig_size[0]*0.04,height=subfig_size[1]*0.4,loc='right')
                norm.lgd = mcolors.Normalize(vmin=min_val*100, vmax=max_val*100)
                sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm.lgd)
                plt.colorbar(sm,cax=ax_lgd,location='left',shrink=0.01,
                             label='change relative to baseline',
                             format="%+.0f %%")

                # title
                ax.title.set_text(timestep)

                # scale lines legend
                ax_sub = inset_axes(ax, width=insetfig_size, height=insetfig_size, loc=10,
                                    bbox_to_anchor=(ax.get_xlim()[0]+3,ax.get_ylim()[1]-5),
                                    bbox_transform=ax.transData)
                ax_sub.title.set_text('Relative Change')
                limits = base_radius*(1+.09*rel_change_scaling)
                ax_sub.set_xlim(-limits, limits)
                ax_sub.set_ylim(-limits, limits)
                ax_sub.axis('off')
                sclLin_sty = ['--',':','-',':']
                sclLin_wth = [1,1,1,1]
                sclLin_rad = [-0.1,-0.05,0,0.05]
                sclLin_col = ['gray','gray','k','gray']
                sclLin_lab = ['-10%','-5%','','+5%']
                shdCirc_rad = 0
                shdCirc_lwd = [3,6,8,10,12,14,16,20,22,24,26,28,30]
                textkw = dict(facecolor='white',linewidth=0,pad=1)
                for i in range(len(sclLin_rad)):
                    circle = plt.Circle((0,0), base_radius*(1+sclLin_rad[i]*rel_change_scaling), linestyle=sclLin_sty[i],
                                        fill = False, edgecolor=sclLin_col[i], linewidth=sclLin_wth[i])
                    ax_sub.add_patch(circle)
                    txt=ax_sub.text(0,base_radius*(1+sclLin_rad[i]*rel_change_scaling),sclLin_lab[i],fontsize=10,
                              backgroundcolor='white',color=sclLin_col[i],horizontalalignment='center',verticalalignment='center')
                    txt.set_bbox(textkw)

                # sector color legends
                ax_sub = inset_axes(ax, width=insetfig_size, height=insetfig_size, loc=10,
                                    bbox_to_anchor=(ax.get_xlim()[0]+10,ax.get_ylim()[1]-5),
                                    bbox_transform=ax.transData)
                wedges, texts = ax_sub.pie(np.ones(len(piedata)), colors=sector_colors, labels=sector_names,
                                         wedgeprops=wedgeprops, counterclock=False, startangle=-270)
                ax_sub.title.set_text('Sectors')

                # save just the subplot
                if not os.path.exists(figdir):
                    os.makedirs(figdir)
                fig.savefig(figdir+'/map-' + plotType +'-'+ sector_thing + '_in_' + scenarios_names[scenario_index] +
                            '_scenario_as_' + plotType + '_time_step_ ' + timestep + '.png',
                            dpi=300,
                            bbox_inches=ax.get_window_extent().transformed(fig.dpi_scale_trans.inverted()).expanded(1.03, 1.06))
                fig.savefig(figdir+'/map-' + plotType +'-'+ sector_thing + '_in_' + scenarios_names[scenario_index] +
                            '_scenario_as_' + plotType + '_time_step_ ' + timestep + '.pdf',
                            bbox_inches=ax.get_window_extent().transformed(fig.dpi_scale_trans.inverted()).expanded(1.03, 1.06))

            # Hide unused subplots
            for time_index in range(len(time_steps), nrows*ncols):  # Adjust the range if the grid size is changed
                if(col==ncols):
                    row+=1
                    col=0
                axes[row, col].axis('off')
                col+=1

            # display the plot
            if showPlots: plt.show()

            # save just the whole figure
            figdir = basefigdir
            if not os.path.exists(figdir):
                os.makedirs(figdir)
            fig.savefig(figdir+'/map-' + plotType +'-'+ sector_thing + '_in_' + scenarios_names[scenario_index] + '_scenario_as_' + plotType + '.png',
                        dpi=300)
            fig.savefig(figdir+'/map-' + plotType +'-'+ sector_thing + '_in_' + scenarios_names[scenario_index] + '_scenario_as_' + plotType + '.pdf')

            plt.close(fig)



#%% test
# plotType = 'dif_rel'
#
# if plotType == 'abs':
#     thing_df = pd.DataFrame({'time': np.repeat(time_steps, len(country_codes)), 'country': country_codes_3 * len(time_steps),
#                              thing:base[thing].flatten()})
# if plotType == 'dif_rel':
#     thing_df = pd.DataFrame({'time': np.repeat(time_steps, len(country_codes)), 'country': country_codes_3 * len(time_steps),
#                              thing:scenarios_dif_rel[scenario_index][thing].flatten()})
#
#
# # define colors
# if plotType == 'abs':
#     cmap = cmap_abs
#     min_val, max_val = min(thing_df[thing]), max(thing_df[thing])
# if plotType == 'dif_rel':
#     cmap = cmap_rel
# norm = mcolors.Normalize(vmin=min_val, vmax=max_val)
# scenario_index = 1
#
# fig, axes = plt.subplots(1, 1, figsize=(subfig_size[0], subfig_size[1]))
# plt.tight_layout()
# fig.suptitle(thing + ' in ' + scenarios_names[scenario_index] + ' scenario as ' + plotType)
# row = 1
# col = 1
# time_index, timestep = 5, 'Q5'
# thing_df_1 = thing_df[thing_df['time']==timestep]
#
# # determine subfigure
# ax = axes
#
# # create the plot
# thing_df_1 = thing_df[thing_df['time']==timestep]
# mergedData = europe.merge(thing_df_1, how='left', left_on='ADM0_A3', right_on='country')
# mergedData.plot(column=thing, cmap=cmap, norm=norm,vmin=min_val,vmax=max_val,
#                 edgecolor='black', linewidth=0.2,ax=ax)
#
# # custom axis
# ax.set_xlim(-10, 35)
# ax.set_ylim(32, 67)
# ax.axis('off')
#
#
#
#
# # arrow for BEL inset
# ax.add_patch(patches.FancyArrowPatch((europe['LABEL_X'][europe['ADM0_A3']=='BEL'].iloc[0],
#                                           europe['LABEL_Y'][europe['ADM0_A3']=='BEL'].iloc[0]),
#                                           (europe['INSET_FIG_X'][europe['ADM0_A3']=='BEL'].iloc[0],
#                                           europe['INSET_FIG_Y'][europe['ADM0_A3']=='BEL'].iloc[0]-1.9),
#                                           color='k', linewidth=0.2,connectionstyle="arc3,rad=-.3"))
#
# # arrow for LUX inset
# ax.add_patch(patches.FancyArrowPatch((europe['LABEL_X'][europe['ADM0_A3']=='LUX'].iloc[0],
#                                           europe['LABEL_Y'][europe['ADM0_A3']=='LUX'].iloc[0]),
#                                           (europe['INSET_FIG_X'][europe['ADM0_A3']=='LUX'].iloc[0]+1.3,
#                                           europe['INSET_FIG_Y'][europe['ADM0_A3']=='LUX'].iloc[0]-1.3),
#                                           color='k', linewidth=0.2,connectionstyle="arc3,rad=-.3"))
#
# # arrow for SVN inset
# ax.add_patch(patches.FancyArrowPatch((europe['LABEL_X'][europe['ADM0_A3']=='SVN'].iloc[0],
#                                           europe['LABEL_Y'][europe['ADM0_A3']=='SVN'].iloc[0]),
#                                           (europe['INSET_FIG_X'][europe['ADM0_A3']=='SVN'].iloc[0]+1.9,
#                                           europe['INSET_FIG_Y'][europe['ADM0_A3']=='SVN'].iloc[0]),
#                                           color='k', linewidth=0.2,connectionstyle="arc3,rad=-.6"))
#
# # arrow for SVK inset
# ax.add_patch(patches.FancyArrowPatch((europe['LABEL_X'][europe['ADM0_A3']=='SVK'].iloc[0]+2,
#                                           europe['LABEL_Y'][europe['ADM0_A3']=='SVK'].iloc[0]),
#                                           (europe['INSET_FIG_X'][europe['ADM0_A3']=='SVK'].iloc[0]-1.3,
#                                           europe['INSET_FIG_Y'][europe['ADM0_A3']=='SVK'].iloc[0]-1.3),
#                                           color='k', linewidth=0.2,connectionstyle="arc3,rad=.1"))
#
# # country inset plots
# for country_index in range(len(country_codes)):
#     print('Making inset ' + country_codes_3[country_index])
#     ax_sub = inset_axes(ax, width=insetfig_size, height=insetfig_size, loc=10,
#                         bbox_to_anchor=(europe[europe['ADM0_A3']==country_codes_3[country_index]]['INSET_FIG_X'],
#                                         europe[europe['ADM0_A3']==country_codes_3[country_index]]['INSET_FIG_Y']),
#                         bbox_transform=ax.transData)
#     text = ax_sub.text(0.3,0,country_codes[country_index],color='gray',ha='center',va='center',weight='bold')
#     text.set_path_effects([path_effects.Stroke(linewidth=3, foreground='white'),
#                        path_effects.Normal()])
#     piedata = base[sector_thing][time_index,country_index,:]
#     addRelChangeStackedBarPlot(piedata,scenarios_dif_rel[scenario_index][sector_thing][time_index,country_index,:],ax_sub)
#     # addBrokenDonutPlot(piedata,ax_sub,halo=True)
#     # addRelChangePiePlot(piedata,ax_sub)
#     # limits = 1+(0.09*rel_change_scaling)
#     # ax_sub.set_xlim(-limits, limits)
#     # ax_sub.set_ylim(-limits, limits)
#     # ax_sub.axis('off')
#     # circle = plt.Circle((0,0), base_radius*(1+0.05*rel_change_scaling), linestyle=':',
#     #                             fill = False, edgecolor='gray', linewidth=1)
#     # ax_sub.add_patch(circle)
#     # shadowArgs = dict(alpha=0.3,antialiased = True, color='white',linewidth=10,linestyle='-')
#     # ax_sub.add_patch(patches.Shadow(circle,0,0,shade=1,**shadowArgs))
#
# # color legend
# ax_lgd = inset_axes(ax,width=subfig_size[0]*0.04,height=subfig_size[1]*0.4,loc='right')
# sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
# plt.colorbar(sm,cax=ax_lgd,location='right',shrink=0.01)
#
# # title
# ax.title.set_text(timestep)
#
# # scale lines legend
# ax_sub = inset_axes(ax, width=insetfig_size, height=insetfig_size, loc=10,
#                     bbox_to_anchor=(ax.get_xlim()[0]+3,ax.get_ylim()[1]-5),
#                     bbox_transform=ax.transData)
# ax_sub.title.set_text('Relative Change')
# limits = base_radius*(1+.09*rel_change_scaling)
# ax_sub.set_xlim(-limits, limits)
# ax_sub.set_ylim(-limits, limits)
# ax_sub.axis('off')
# sclLin_sty = ['--',':','-',':']
# sclLin_wth = [1,1,1,1]
# sclLin_rad = [-0.1,-0.05,0,0.05]
# sclLin_col = ['gray','gray','k','gray']
# sclLin_lab = ['-10%','-5%','','+5%']
# shdCirc_rad = 0
# shdCirc_lwd = [3,6,8,10,12,14,16,20,22,24,26,28,30]
# textkw = dict(facecolor='white',linewidth=0,pad=1)
# for i in range(len(sclLin_rad)):
#     circle = plt.Circle((0,0), base_radius*(1+sclLin_rad[i]*rel_change_scaling), linestyle=sclLin_sty[i],
#                         fill = False, edgecolor=sclLin_col[i], linewidth=sclLin_wth[i])
#     ax_sub.add_patch(circle)
#     txt=ax_sub.text(0,base_radius*(1+sclLin_rad[i]*rel_change_scaling),sclLin_lab[i],fontsize=10,
#               backgroundcolor='white',color=sclLin_col[i],horizontalalignment='center',verticalalignment='center')
#     txt.set_bbox(textkw)
#
# # sector color legends
# ax_sub = inset_axes(ax, width=insetfig_size, height=insetfig_size, loc=10,
#                     bbox_to_anchor=(ax.get_xlim()[0]+10,ax.get_ylim()[1]-5),
#                     bbox_transform=ax.transData)
# wedges, texts = ax_sub.pie(np.ones(len(piedata)), colors=sector_colors, labels=sector_names,
#                           wedgeprops=wedgeprops, counterclock=False, startangle=-270)
# ax_sub.title.set_text('Sectors')
