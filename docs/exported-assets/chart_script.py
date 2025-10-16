import plotly.graph_objects as go
import plotly.express as px
import json

# Parse the layer data
layers_data = {
    "layers": [
        {"name": "UI Layer", "components": ["iPhone App (SwiftUI)", "iPad App (Adaptive)", "StandBy Widgets", "Screensaver Display"], "color": "#E3F2FD"}, 
        {"name": "Presentation Layer", "components": ["ViewModels (MVVM)", "Combine Framework", "Navigation Coordinators"], "color": "#F3E5F5"}, 
        {"name": "Business Logic Layer", "components": ["Audio Processing Manager", "Snore Detection (Core ML)", "Analytics Engine", "Sleep Session Manager", "Health Data Manager"], "color": "#E8F5E8"}, 
        {"name": "Data Layer", "components": ["Core Data Stack", "CloudKit Sync", "HealthKit Integration", "Audio File Storage"], "color": "#FFF3E0"}, 
        {"name": "Device/System Layer", "components": ["AVAudioEngine", "Core ML Framework", "Create ML Training", "Microphone Hardware", "Apple Watch"], "color": "#FFEBEE"}
    ]
}

# Create figure
fig = go.Figure()

# Define layout parameters
layer_height = 1.5
component_width = 2.2
component_height = 0.6
spacing_x = 0.3
spacing_y = 0.2
start_y = 8

# Color mapping for borders
border_colors = {
    "#E3F2FD": "#1976D2",
    "#F3E5F5": "#7B1FA2", 
    "#E8F5E8": "#388E3C",
    "#FFF3E0": "#F57C00",
    "#FFEBEE": "#D32F2F"
}

# Store component positions for drawing arrows
component_positions = {}

# Draw each layer
for layer_idx, layer in enumerate(layers_data["layers"]):
    layer_y = start_y - (layer_idx * (layer_height + spacing_y))
    
    # Calculate total width needed for components
    total_width = len(layer["components"]) * component_width + (len(layer["components"]) - 1) * spacing_x
    start_x = -total_width / 2
    
    # Draw layer background
    fig.add_shape(
        type="rect",
        x0=start_x - 0.5,
        y0=layer_y - layer_height/2 - 0.1,
        x1=start_x + total_width + 0.5,
        y1=layer_y + layer_height/2 + 0.1,
        fillcolor=layer["color"],
        opacity=0.3,
        line=dict(width=0)
    )
    
    # Add layer title
    fig.add_annotation(
        x=start_x - 0.8,
        y=layer_y,
        text=f"<b>{layer['name']}</b>",
        showarrow=False,
        font=dict(size=12, color="black"),
        textangle=-90,
        xanchor="center",
        yanchor="middle"
    )
    
    # Draw components
    for comp_idx, component in enumerate(layer["components"]):
        x_pos = start_x + comp_idx * (component_width + spacing_x) + component_width/2
        
        # Store position for arrows
        component_positions[component] = (x_pos, layer_y)
        
        # Draw component box
        fig.add_shape(
            type="rect",
            x0=x_pos - component_width/2,
            y0=layer_y - component_height/2,
            x1=x_pos + component_width/2,
            y1=layer_y + component_height/2,
            fillcolor=layer["color"],
            line=dict(color=border_colors[layer["color"]], width=2)
        )
        
        # Add component text
        fig.add_annotation(
            x=x_pos,
            y=layer_y,
            text=component,
            showarrow=False,
            font=dict(size=10, color="black"),
            xanchor="center",
            yanchor="middle"
        )

# Define data flow connections
connections = [
    ("iPhone App (SwiftUI)", "ViewModels (MVVM)"),
    ("iPad App (Adaptive)", "ViewModels (MVVM)"),
    ("StandBy Widgets", "Navigation Coordinators"),
    ("Screensaver Display", "Navigation Coordinators"),
    
    ("ViewModels (MVVM)", "Sleep Session Manager"),
    ("Combine Framework", "Audio Processing Manager"),
    ("Combine Framework", "Analytics Engine"),
    ("Navigation Coordinators", "ViewModels (MVVM)"),
    
    ("Audio Processing Manager", "Snore Detection (Core ML)"),
    ("Audio Processing Manager", "Audio File Storage"),
    ("Snore Detection (Core ML)", "Analytics Engine"),
    ("Analytics Engine", "Core Data Stack"),
    ("Sleep Session Manager", "Health Data Manager"),
    ("Sleep Session Manager", "Core Data Stack"),
    ("Health Data Manager", "HealthKit Integration"),
    
    ("Core Data Stack", "CloudKit Sync"),
    ("HealthKit Integration", "Apple Watch"),
    ("Audio File Storage", "AVAudioEngine"),
    
    ("Snore Detection (Core ML)", "Core ML Framework"),
    ("AVAudioEngine", "Microphone Hardware"),
    ("Core ML Framework", "Create ML Training")
]

# Draw arrows for connections
for start_comp, end_comp in connections:
    if start_comp in component_positions and end_comp in component_positions:
        start_pos = component_positions[start_comp]
        end_pos = component_positions[end_comp]
        
        # Calculate arrow positions
        if start_pos[1] > end_pos[1]:  # Downward arrow
            start_y = start_pos[1] - component_height/2
            end_y = end_pos[1] + component_height/2
        else:  # Upward arrow
            start_y = start_pos[1] + component_height/2
            end_y = end_pos[1] - component_height/2
            
        # Add arrow
        fig.add_annotation(
            x=end_pos[0],
            y=end_y,
            ax=start_pos[0],
            ay=start_y,
            arrowhead=2,
            arrowsize=0.8,
            arrowwidth=1.5,
            arrowcolor="#666666",
            showarrow=True,
            text=""
        )

# Update layout
fig.update_layout(
    title="iOS Snore Detection App Architecture",
    showlegend=False,
    xaxis=dict(
        showgrid=False,
        showticklabels=False,
        zeroline=False,
        range=[-8, 8]
    ),
    yaxis=dict(
        showgrid=False,
        showticklabels=False,
        zeroline=False,
        range=[0, 10]
    ),
    plot_bgcolor="white",
    paper_bgcolor="white"
)

# Save the chart
fig.write_image("architecture_diagram.png")
fig.write_image("architecture_diagram.svg", format="svg")

print("Architecture diagram created successfully!")
print("Saved as: architecture_diagram.png and architecture_diagram.svg")