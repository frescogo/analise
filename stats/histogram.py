import sys
import os
import math
import matplotlib.pyplot as plt
import numpy as np

def hist (xs, clr, is_step) :
    if is_step:
        plt.hist(xs, bins=20, color=clr, range=(0,100), histtype='step')
    else:
        plt.hist(xs, bins=20, color=clr, range=(0,100))

inp = sys.argv[1]
out = sys.argv[2] + '/' + os.path.splitext(os.path.basename(inp))[0] + '.png'

exec(open(inp).read())

plt.rc('figure', figsize=(8, 6))

f1 = plt.subplot(3, 1, 1)

stats = 'Media:    ' + "{0:05.2f}".format(GAME['pontos'][1]) + '    \n' + \
        'Equil.:   ' + "{0:05.2f}".format(GAME['pontos'][2]) + ' (-)\n' + \
        'Quedas:   ' + "{0:5d}".format(GAME['pontos'][3]) + '% (-)\n' + \
        'FINAL:    ' + "{0:05.2f}".format(GAME['pontos'][0]) + '    '
plt.text(0.99, 0.95, stats, va='top', ha='right', transform=f1.transAxes, family='monospace', size=8)

stats = 'Golpes: ' + str(GAME['golpes']) + '\n' + \
        'Ritmo:  ' + str(GAME['ritmo'])  + ' km/h\n' + \
        'Quedas: ' + str(GAME['quedas'])
plt.text(0.01, 0.95, stats, va='top', ha='left', transform=f1.transAxes, family='monospace', size=8)

plt.title(GAME[0]['nome'] + ' / ' +
          GAME[1]['nome'] + ' / ' +
          GAME['config']  + ' / ' +
          GAME['timestamp'])

plt.xlabel('Velocidade (km/h)')
plt.xlim(xmax=100)
plt.ylabel('Golpes')
plt.ylim(ymax=50)
plt.grid(axis='y')
hist(GAME[0]['hits']+GAME[1]['hits'], ['gray'], False)
hist(GAME[0]['hits'], ['red'],  True)
hist(GAME[1]['hits'], ['blue'], True)
plt.axvline(GAME['ritmo'], color='k', linestyle='dashed', linewidth=1)
#plt.legend()

def atleta (i):
    f = plt.subplot(3, 1, i+2)

    #print(i, GAME[i]['pontos'][0])
    stats = 'Golpes:   ' + "{0:5d}".format(GAME[i]['golpes'])       + '\n' + \
            'Pontos:   ' + "{0:05.2f}".format(GAME[i]['pontos'][0]) + '\n' + \
            'Volume:   ' + "{0:05.2f}".format(GAME[i]['pontos'][1]) + '\n' + \
            'Normal:   ' + "{0:05.2f}".format(GAME[i]['pontos'][2]) + '\n' + \
            'Revés:    ' + "{0:05.2f}".format(GAME[i]['pontos'][3]) + '\n'
    plt.text(0.99, 0.95, stats, va='top', ha='right', transform=f.transAxes, family='monospace', size=8)

    def maior0 (x):
        return x>0

    plt.title(GAME[i]['nome'])
    plt.xlabel('Velocidade (km/h)')
    plt.xlim(xmax=100)
    plt.ylabel('Golpes')
    plt.ylim(ymax=50)
    plt.grid(axis='y')
    hist(GAME[i]['hits'], ['gray'], False)
    hist(list(filter(maior0,GAME[i]['normal'])), ['green'], False)
    hist(list(filter(maior0,GAME[i]['reves'])),  ['red'], False)

    pts = GAME[i]['pontos']
    plt.axvline(pts[0], color='k', linestyle='dashed', linewidth=1)
    plt.text(pts[0],40,'pts',fontsize=7,rotation=90,bbox=dict(facecolor='white'))
    plt.axvline(pts[1], color='blue',   linestyle='dashed', linewidth=1)
    plt.text(pts[1],40,'vol',fontsize=7,rotation=90,bbox=dict(facecolor='white'))
    plt.axvline(pts[2], color='green',  linestyle='dashed', linewidth=1)
    plt.text(pts[2],40,'nrm',fontsize=7,rotation=90,bbox=dict(facecolor='white'))
    plt.axvline(pts[3], color='red',    linestyle='dashed', linewidth=1)
    plt.text(pts[3],40,'rev',fontsize=7,rotation=90,bbox=dict(facecolor='white'))

atleta(0)
atleta(1)

plt.tight_layout(pad=1, w_pad=1, h_pad=1)
plt.savefig(out)
