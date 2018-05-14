from __future__ import print_function

import matplotlib.pyplot as plt
import networkx as nx

def generate_short_dumb_bell (n):
    G = nx.Graph()
    G.add_node('L')
    G.add_node('R')

    for s in ['L', 'R']:
        for i in xrange(n):
            G.add_node ('{}{}'.format(s, i))
            G.add_edge(s, '{}{}'.format(s, i))
            for j in xrange (i + 1, n):
                G.add_edge ('{}{}'.format (s, i), '{}{}'.format (s, j)) 

    G.add_edge('L', 'R')
    plt.clf ()
    nx.draw(G, labels=True)
    print (nx.to_numpy_matrix(G).astype(int))

def generate_long_dumb_bell (n, pole):
    G = nx.Graph ()
    G.add_node ('L')
    G.add_node ('R')
    G.add_node ('C')
    G.add_edge ('L', 'C')
    G.add_edge ('C', 'R')
    for s in ['L', 'R']:
        for i in xrange(n):
            G.add_node ('{}{}'.format (s, i))
            G.add_edge (s, '{}{}'.format (s, i))
            if pole == 'full':
                for j in xrange (i + 1, n):
                    G.add_edge ('{}{}'.format (s, i), '{}{}'.format (s, j))
            elif pole == 'whiskers':
                pass
            else:
                raise 'Unknown pole type'
    return report (G)

def report (graph):
    matrix = nx.to_numpy_matrix (graph).astype (int)
    print ('----------------------------------')
    print ('   case XXX')
    print ('      N = [')
    for row in matrix:
        for c in row.flat:
            print (c, end = ' ')
        print (';')
    print ('      ];')
    print ('      mds = YYY')
    print ('----------------------------------')
    for row in matrix:
        for i, c in enumerate (row.flat):
            print (c, end = ',' if i + 1 < matrix.shape [0] else '\n')
    print ('----------------------------------')
    return matrix

