# python3 histogram.py sample/frescogo-2021_09_26_15_43_39-patricia-didi.py sample/

import sys
import os
import math
import matplotlib.pyplot as plt
import numpy as np

inp = sys.argv[1]
out = sys.argv[2] + '/' + os.path.splitext(os.path.basename(inp))[0] + '.png'

exec(open(inp).read())

plt.rc('figure', figsize=(6,5))
bins = np.linspace(40, 90, 20)
f1 = plt.subplot(3,1,1)

stats = 'Pontos: ' + "{:5d}".format(GAME['final'])  + '\n' + \
        'Golpes: ' + "{:5d}".format(GAME['golpes']) + '\n' + \
        'Quedas: ' + "{:5d}".format(GAME['quedas'])
plt.text(0.01, 0.95, stats, va='top', ha='left', transform=f1.transAxes, family='monospace', size=8)

stats = 'Médias    \n' + \
        '300+: ' + "{:.2f}".format(GAME['m300']) + '  \n' + \
        '100+: ' + "{:.2f}".format(GAME['m100']) + '  \n' + \
        ' 50-: ' + "{:.2f}".format(GAME['m50'])  + '  '
plt.text(1, 0.95, stats, va='top', ha='right', transform=f1.transAxes, family='monospace', size=8)

plt.title(GAME[0]['nome'] + ' / ' +
          GAME[1]['nome'] + ' / ' +
          GAME['timestamp'])

plt.xlabel('Velocidade')
plt.xlim(xmin=40,xmax=90)
plt.ylabel('Golpes')
plt.ylim(ymax=60)
plt.grid(axis='y')
plt.hist(GAME[0]['hits']+GAME[1]['hits'], bins, color=['gray'], alpha=0.75)
plt.hist(GAME[0]['hits'], bins, color=['darkgreen'], histtype='step')
plt.hist(GAME[1]['hits'], bins, color=['blue'], histtype='step')
plt.axvline(GAME['m300'], color='k',   linestyle='dashed', linewidth=1)
plt.axvline(GAME['m100'], color='red', linestyle='dashed', linewidth=1)
plt.axvline(GAME['m50'],  color='red', linestyle='dashed', linewidth=1)
#plt.legend()

def atleta (i,clr):
    f = plt.subplot(3, 1, i+2)

    #print(i, GAME[i]['pontos'][0])
    stats = 'Pontos: ' + "{:5d}".format(GAME[i]['pontos']) + '\n' + \
            'Golpes: ' + "{:5d}".format(GAME[i]['golpes']) + '\n' + \
            'Vel-/+: ' + str(GAME[i]['min']) + '/' + str(GAME[i]['max'])
    plt.text(0.01, 0.95, stats, va='top', ha='left', transform=f.transAxes, family='monospace', size=8)

    stats = 'Médias    \n' + \
            '150+: ' + "{:.2f}".format(GAME[i]['m150']) + '  \n' + \
            ' 50+: ' + "{:.2f}".format(GAME[i]['m50'])  + '  \n' + \
            ' 25-: ' + "{:.2f}".format(GAME[i]['m25'])  + '  '
    plt.text(1, 0.95, stats, va='top', ha='right', transform=f.transAxes, family='monospace', size=8)

    plt.title(GAME[i]['nome'])
    plt.xlabel('Velocidade')
    plt.xlim(xmin=40,xmax=90)
    plt.ylabel('Golpes')
    plt.ylim(ymax=60)
    plt.grid(axis='y')
    plt.hist(GAME[i]['hits'], bins, color=[clr], alpha=0.75)
    plt.axvline(GAME[i]['m150'], color='k',   linestyle='dashed', linewidth=1)
    plt.axvline(GAME[i]['m50'],  color='red', linestyle='dashed', linewidth=1)
    plt.axvline(GAME[i]['m25'],  color='red', linestyle='dashed', linewidth=1)

atleta(0, 'darkgreen')
atleta(1, 'blue')

plt.tight_layout(pad=1, w_pad=1, h_pad=1)
plt.savefig(out)
