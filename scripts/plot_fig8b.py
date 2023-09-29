import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import os
import csv 
from plot_fig8a import read_search_cost

src_data_path = "results"
figure_save_path = "figures"

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

if __name__ == "__main__":
    fig, ax = plt.subplots(figsize=(5, 3))
    plt.grid(color='lightgrey', linestyle='--', linewidth=0.5, zorder=0)
    prop_cycle = plt.rcParams['axes.prop_cycle']
    colors = prop_cycle.by_key()['color']
    blue, orange, green, red = colors[:4]

    xaxis = ('# of GPUs', [4, 8, 16, 32])
    nbars = 2
    inds = np.arange(len(xaxis[1]))
    width = 0.38
    line_config = dict(edgecolor='white')

    # bar2 = ('Alpa', np.array([2056, 10973, 9258, 44743]) / 60 / 60)
    # bar3 = ('Aceso', np.array([111, 206, 208, 225]) / 60 / 60)
    alpa_all_cost, aceso_all_cost = read_search_cost("search_cost_large_resnet.csv")
    bar2 = ('Alpa', np.array(alpa_all_cost) / 60 / 60) # hour
    bar3 = ('Aceso', np.array(aceso_all_cost) / 60 / 60)    

    bar2_plot = ax.bar(inds - width / 2, np.array(bar2[1]), width, label=bar2[0], hatch='/', color=green, **line_config, zorder=100)
    bar3_plot = ax.bar(inds + width / 2, np.array(bar3[1]), width, label=bar3[0], color=blue, **line_config, zorder=100)

    plt.legend(bbox_to_anchor=(0.17, 0.97, 1.2, .12), loc='lower left', ncol=5,
               frameon=False, handlelength=1.0, handletextpad=0.2, columnspacing=0.6,
               borderaxespad=0., prop={'size': 21})

    ax.set_xlabel(xaxis[0], dict(size=22))
    ax.tick_params(axis='x', labelsize=22)
    ax.set_ylabel('Time (Hour)', dict(size=22))
    ax.tick_params(axis='y', labelsize=22)

    plt.xlim((-0.7, 3.7))
    plt.ylim((0, 13))
    plt.yticks([0, 4, 8, 12],
               ['0', '4', '8', '12'])
    plt.xticks([0, 1, 2, 3],
               ['4', '8', '16', '32'])

    ## DEBUG USE
    if len(aceso_all_cost) < 4:
        aceso_all_cost = [aceso_all_cost[0] for _ in range(4)]

    cycles_str = [f"   {aceso_all_cost[0]:.0f}$\,$sec", f"   {aceso_all_cost[1]:.0f}$\,$sec", f"   {aceso_all_cost[2]:.0f}$\,$sec", f"   {aceso_all_cost[3]:.0f}$\,$sec"]
    for rect, s in zip(bar3_plot, cycles_str):
        height = rect.get_height()
        ax.text(rect.get_x() + rect.get_width()*0.5, -1.8,
                s, ha='center', va='bottom', fontsize=21, color=blue, rotation = 'vertical')

    fig.tight_layout()
    plt.subplots_adjust(left=0.175, bottom=0.24, right=0.985, top=0.87)

    # plt.show()
    if not os.path.exists(figure_save_path):
        os.makedirs(figure_save_path)
    fig.savefig(os.path.join(figure_save_path, "fig8b.pdf"), dpi=600)

