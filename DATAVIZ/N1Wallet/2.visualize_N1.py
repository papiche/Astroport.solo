#!/usr/bin/env python3
# pip install networkx matplotlib
import json
import networkx as nx
import matplotlib.pyplot as plt

def load_data():
    # Load incomes and outcomes
    with open('tmp/N1.incomes.json', 'r') as f:
        incomes = json.load(f)

    with open('tmp/N1.outcomes.json', 'r') as f:
        outcomes = json.load(f)

    return incomes, outcomes

def create_graph(incomes, outcomes):
    G = nx.DiGraph()

    # Add nodes (wallets)
    for entry in incomes + outcomes:
        pubkey = entry['pubkey']
        G.add_node(pubkey, amount=entry['amount'])

    # Add edges for incomes
    for entry in incomes:
        pubkey = entry['pubkey']
        amount = entry['amount']
        G.add_edge('Source', pubkey, amount=amount, color='green')

    # Add edges for outcomes
    for entry in outcomes:
        pubkey = entry['pubkey']
        amount = entry['amount']
        G.add_edge(pubkey, 'Destination', amount=amount, color='red')

    # Create "Transaction" node and edges
    G.add_node('Transaction', amount=0)  # Initial amount for Transaction node
    for node, data in G.nodes(data=True):
        if node == 'Source':
            for successor in G.successors(node):
                G.add_edge(node, successor, amount=G[node][successor]['amount'], color='green')
        elif node == 'Destination':
            for predecessor in G.predecessors(node):
                G.add_edge(predecessor, node, amount=G[predecessor][node]['amount'], color='red')

    return G

def plot_graph(G):
    # Calculate node sizes (based on the presence of 'amount' attribute)
    node_sizes = [abs(data['amount']) * 50 if 'amount' in data else 100 for _, data in G.nodes(data=True)]
    node_colors = ['green' if node == 'Source' else 'red' if node == 'Destination' else 'blue' for node in G.nodes()]
    edge_colors = [data['color'] for _, _, data in G.edges(data=True)]
    edge_labels = {(u, v): f"{G[u][v]['amount']}" for u, v in G.edges()}
    pos = nx.spring_layout(G, seed=42)

    # Center the graph around 'Transaction' node
    pos['Transaction'] = [0, 0]

    # Draw nodes
    nx.draw_networkx_nodes(G, pos, node_size=node_sizes, node_color=node_colors, alpha=0.7)

    # Draw edges
    nx.draw_networkx_edges(G, pos, edge_color=edge_colors, width=1.0, alpha=0.7)

    # Draw labels
    nx.draw_networkx_labels(G, pos, font_size=10, font_color='black')

    # Draw edge labels
    nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels, font_color='black')

    plt.title("Wallet Transactions tmp/Network")
    plt.axis('off')
    plt.show()

if __name__ == "__main__":
    incomes, outcomes = load_data()
    G = create_graph(incomes, outcomes)
    plot_graph(G)

