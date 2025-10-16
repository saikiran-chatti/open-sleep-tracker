# Create a comprehensive flowchart using Plotly since mermaid is having connection issues
import plotly.graph_objects as go
import plotly.express as px
import numpy as np

# Define the flowchart structure with better positioning
nodes = {
    'App Launch': {'pos': (0, 12), 'type': 'start', 'color': '#1FB8CD'},
    'First Time?': {'pos': (0, 11), 'type': 'decision', 'color': '#DB4545'},
    'Permissions': {'pos': (-2, 10), 'type': 'process', 'color': '#2E8B57'},
    'Main Dashboard': {'pos': (0, 9), 'type': 'process', 'color': '#5D878F'},
    'Schedule': {'pos': (-1.5, 8), 'type': 'process', 'color': '#D2BA4C'},
    'Manual Start': {'pos': (1.5, 8), 'type': 'process', 'color': '#B4413C'},
    'Recording': {'pos': (0, 7), 'type': 'process', 'color': '#964325'},
    'Charging?': {'pos': (0, 6), 'type': 'decision', 'color': '#DB4545'},
    'StandBy Mode': {'pos': (-1.5, 5), 'type': 'special', 'color': '#944454'},
    'Analysis': {'pos': (0, 4), 'type': 'process', 'color': '#2E8B57'},
    'Results': {'pos': (0, 3), 'type': 'process', 'color': '#1FB8CD'},
    'Health Sync': {'pos': (-1.5, 2), 'type': 'process', 'color': '#5D878F'},
    'Trends': {'pos': (0, 1), 'type': 'end', 'color': '#D2BA4C'}
}

# Define connections
connections = [
    ('App Launch', 'First Time?'),
    ('First Time?', 'Permissions'),
    ('First Time?', 'Main Dashboard'),
    ('Permissions', 'Main Dashboard'),
    ('Main Dashboard', 'Schedule'),
    ('Main Dashboard', 'Manual Start'),
    ('Schedule', 'Recording'),
    ('Manual Start', 'Recording'),
    ('Recording', 'Charging?'),
    ('Charging?', 'StandBy Mode'),
    ('Charging?', 'Analysis'),
    ('StandBy Mode', 'Analysis'),
    ('Analysis', 'Results'),
    ('Results', 'Health Sync'),
    ('Results', 'Trends'),
    ('Health Sync', 'Trends')
]

# Create the figure
fig = go.Figure()

# Add connection lines first (so they appear behind nodes)
for start, end in connections:
    start_pos = nodes[start]['pos']
    end_pos = nodes[end]['pos']
    
    fig.add_trace(go.Scatter(
        x=[start_pos[0], end_pos[0]], 
        y=[start_pos[1], end_pos[1]],
        mode='lines',
        line=dict(color='#13343B', width=3),
        showlegend=False,
        hoverinfo='skip'
    ))
    
    # Add arrowheads
    dx = end_pos[0] - start_pos[0]
    dy = end_pos[1] - start_pos[1]
    length = np.sqrt(dx**2 + dy**2)
    if length > 0:
        # Normalize and scale for arrow
        dx_norm = dx / length * 0.3
        dy_norm = dy / length * 0.3
        
        # Arrow position (slightly before the end node)
        arrow_x = end_pos[0] - dx_norm * 0.8
        arrow_y = end_pos[1] - dy_norm * 0.8
        
        fig.add_annotation(
            x=arrow_x, y=arrow_y,
            ax=arrow_x - dx_norm, ay=arrow_y - dy_norm,
            xref='x', yref='y',
            axref='x', ayref='y',
            arrowhead=2,
            arrowsize=1.5,
            arrowwidth=2,
            arrowcolor='#13343B',
            showarrow=True
        )

# Add nodes
for node, info in nodes.items():
    x, y = info['pos']
    color = info['color']
    node_type = info['type']
    
    # Determine marker size and shape based on type
    if node_type == 'decision':
        marker_size = 80
        marker_symbol = 'diamond'
    elif node_type in ['start', 'end']:
        marker_size = 70
        marker_symbol = 'circle'
    else:
        marker_size = 75
        marker_symbol = 'square'
    
    fig.add_trace(go.Scatter(
        x=[x], y=[y],
        mode='markers+text',
        marker=dict(
            size=marker_size, 
            color=color, 
            symbol=marker_symbol,
            line=dict(width=3, color='#13343B')
        ),
        text=node,
        textposition='middle center',
        textfont=dict(size=11, color='#13343B', family='Arial Black'),
        showlegend=False,
        name=node,
        hovertemplate=f'<b>{node}</b><br>Type: {node_type}<extra></extra>'
    ))

# Update layout
fig.update_layout(
    title='Snore Detection App User Flow',
    xaxis=dict(
        showgrid=False, 
        zeroline=False, 
        showticklabels=False,
        range=[-3, 3]
    ),
    yaxis=dict(
        showgrid=False, 
        zeroline=False, 
        showticklabels=False,
        range=[0, 13]
    ),
    plot_bgcolor='rgba(0,0,0,0)',
    paper_bgcolor='rgba(0,0,0,0)',
    font=dict(size=12, color='#13343B'),
    showlegend=False
)

# Save the chart as both PNG and SVG
fig.write_image('snore_app_flow.png')
fig.write_image('snore_app_flow.svg', format='svg')

print("Snore detection app flowchart created successfully!")
print("Chart shows the complete user journey from app launch to trends analysis")
print("Includes decision points for first-time users and device charging status")